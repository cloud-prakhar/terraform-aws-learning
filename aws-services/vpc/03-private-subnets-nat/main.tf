data "aws_availability_zones" "available" {
  state = "available"
}

locals {
  # Two AZs: if one data centre has a problem, the other keeps running.
  azs = slice(data.aws_availability_zones.available.names, 0, 2)

  # cidrsubnet("10.0.0.0/16", 8, n) = 10.0.n.0/24 (256 addresses; AWS
  # reserves 5 of them in every subnet).
  public_subnets  = { for i, az in local.azs : az => cidrsubnet(var.vpc_cidr, 8, i) }      # 10.0.0.0/24, 10.0.1.0/24
  private_subnets = { for i, az in local.azs : az => cidrsubnet(var.vpc_cidr, 8, i + 10) } # 10.0.10.0/24, 10.0.11.0/24
}

resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "${var.name}-vpc"
  }
}

resource "aws_subnet" "public" {
  for_each = local.public_subnets

  vpc_id            = aws_vpc.main.id
  availability_zone = each.key
  cidr_block        = each.value

  tags = {
    Name = "${var.name}-public-${each.key}"
    Tier = "public"
  }
}

resource "aws_subnet" "private" {
  for_each = local.private_subnets

  vpc_id            = aws_vpc.main.id
  availability_zone = each.key
  cidr_block        = each.value

  tags = {
    Name = "${var.name}-private-${each.key}"
    Tier = "private"
  }
}

# ------------------------- NEW IN STEP 02 -------------------------------

# The internet gateway is the VPC's door to the internet. It is
# horizontally scaled and highly available; there is no hourly charge
# for the gateway itself.
resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "${var.name}-igw"
  }
}

# Every VPC has a "main" route table with a single local route
# (10.0.0.0/16 → local) so subnets can talk to each other. We create a
# separate table for public subnets rather than editing the main one.
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "${var.name}-public"
  }
}

# THIS route is what makes a subnet "public".
resource "aws_route" "public_internet" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.main.id
}

resource "aws_route_table_association" "public" {
  for_each = aws_subnet.public

  subnet_id      = each.value.id
  route_table_id = aws_route_table.public.id
}

# Private subnets get their own table. Step 03 adds a NAT route to it.
resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "${var.name}-private"
  }
}

resource "aws_route_table_association" "private" {
  for_each = aws_subnet.private

  subnet_id      = each.value.id
  route_table_id = aws_route_table.private.id
}

# ------------------------- NEW IN STEP 03 -------------------------------

# COST WARNING: a NAT gateway is billed for every hour it exists plus
# every GB it processes, and its Elastic IP is billed as a public IPv4
# address. Destroy this lab when you are done.

# A static public IPv4 address for the NAT gateway. All outbound
# traffic from private subnets appears to come from this address.
resource "aws_eip" "nat" {
  domain = "vpc"

  tags = {
    Name = "${var.name}-nat"
  }

  # The EIP is only usable once the VPC has an internet gateway.
  depends_on = [aws_internet_gateway.main]
}

# The NAT gateway sits in a PUBLIC subnet (it needs the IGW route) and
# lets private instances start outbound connections (updates, AWS APIs)
# while nothing on the internet can start a connection to them.
resource "aws_nat_gateway" "main" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.public[local.azs[0]].id

  tags = {
    Name = "${var.name}-nat"
  }

  depends_on = [aws_internet_gateway.main]
}

# THIS route is what gives a private subnet outbound-only internet.
# Learning shortcut: one NAT gateway for both AZs. Production usually
# runs one per AZ so losing an AZ does not break the other AZ's egress.
resource "aws_route" "private_nat" {
  route_table_id         = aws_route_table.private.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.main.id
}

# Every VPC comes with a "default" security group that allows all
# traffic between its members. aws_default_security_group ADOPTS that
# existing group (it cannot be created or deleted); declaring it with no
# rules removes the allow rules, so nothing can accidentally rely on it.
resource "aws_default_security_group" "main" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "${var.name}-default-deny"
  }
}
