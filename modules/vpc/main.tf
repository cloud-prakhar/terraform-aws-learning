data "aws_availability_zones" "available" {
  state = "available"
}

locals {
  azs = slice(data.aws_availability_zones.available.names, 0, var.az_count)

  # /16 + 8 bits = /24 subnets (256 addresses each).
  # Public subnets use netnums 0,1,2 → 10.0.0.0/24, 10.0.1.0/24, ...
  # Private subnets use 10,11,12   → 10.0.10.0/24, 10.0.11.0/24, ...
  # The gap leaves room to add public subnets later without renumbering.
  public_subnets = {
    for index, az in local.azs : az => cidrsubnet(var.cidr_block, 8, index)
  }
  private_subnets = var.create_private_subnets ? {
    for index, az in local.azs : az => cidrsubnet(var.cidr_block, 8, index + 10)
  } : {}

  create_nat = var.enable_nat_gateway && var.create_private_subnets
}

resource "aws_vpc" "this" {
  cidr_block = var.cidr_block

  # Needed for private DNS names and for many AWS services (e.g. SSM,
  # VPC endpoints) to resolve correctly inside the VPC.
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = merge(var.tags, { Name = var.name })
}

# Every VPC comes with a "default" security group that allows all
# traffic between its members. Adopting it with no rules removes those
# rules, so nothing can accidentally rely on it.
resource "aws_default_security_group" "this" {
  vpc_id = aws_vpc.this.id
  tags   = merge(var.tags, { Name = "${var.name}-default-deny" })
}

# ------------------------------ public tier ------------------------------

resource "aws_internet_gateway" "this" {
  vpc_id = aws_vpc.this.id
  tags   = merge(var.tags, { Name = "${var.name}-igw" })
}

resource "aws_subnet" "public" {
  for_each = local.public_subnets

  vpc_id                  = aws_vpc.this.id
  availability_zone       = each.key
  cidr_block              = each.value
  map_public_ip_on_launch = false # instances opt in explicitly

  tags = merge(var.tags, { Name = "${var.name}-public-${each.key}", Tier = "public" })
}

# A subnet is "public" only because its route table sends 0.0.0.0/0 to
# an internet gateway. Nothing else makes it public.
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.this.id
  tags   = merge(var.tags, { Name = "${var.name}-public" })
}

resource "aws_route" "public_internet" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.this.id
}

resource "aws_route_table_association" "public" {
  for_each = aws_subnet.public

  subnet_id      = each.value.id
  route_table_id = aws_route_table.public.id
}

# ------------------------------ private tier -----------------------------

resource "aws_subnet" "private" {
  for_each = local.private_subnets

  vpc_id            = aws_vpc.this.id
  availability_zone = each.key
  cidr_block        = each.value

  tags = merge(var.tags, { Name = "${var.name}-private-${each.key}", Tier = "private" })
}

resource "aws_route_table" "private" {
  count = var.create_private_subnets ? 1 : 0

  vpc_id = aws_vpc.this.id
  tags   = merge(var.tags, { Name = "${var.name}-private" })
}

resource "aws_route_table_association" "private" {
  for_each = aws_subnet.private

  subnet_id      = each.value.id
  route_table_id = aws_route_table.private[0].id
}

# COST: a NAT gateway is billed per hour plus per GB processed, and its
# Elastic IP is billed as a public IPv4 address. One shared NAT gateway
# is a cost-saving choice; production usually runs one per AZ so an AZ
# outage does not cut off the other AZs.
resource "aws_eip" "nat" {
  count = local.create_nat ? 1 : 0

  domain = "vpc"
  tags   = merge(var.tags, { Name = "${var.name}-nat" })

  depends_on = [aws_internet_gateway.this]
}

resource "aws_nat_gateway" "this" {
  count = local.create_nat ? 1 : 0

  allocation_id = aws_eip.nat[0].id
  # A NAT gateway lives in a PUBLIC subnet so it can reach the IGW.
  subnet_id = aws_subnet.public[local.azs[0]].id
  tags      = merge(var.tags, { Name = "${var.name}-nat" })

  depends_on = [aws_internet_gateway.this]
}

resource "aws_route" "private_nat" {
  count = local.create_nat ? 1 : 0

  route_table_id         = aws_route_table.private[0].id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.this[0].id
}
