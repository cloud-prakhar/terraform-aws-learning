# Three tiers across multiple AZs:
#   public  – load balancers, NAT gateways  (route to internet gateway)
#   app     – application servers           (route to NAT, if enabled)
#   data    – databases                     (no internet route at all)

data "aws_availability_zones" "available" {
  state = "available"
}

locals {
  azs = slice(data.aws_availability_zones.available.names, 0, var.az_count)

  # One /20 per subnet (4,096 addresses). Tier offsets 0 / 4 / 8 reserve
  # four /20 slots per tier, so a fourth AZ can be added later without
  # renumbering existing subnets.
  #   public: 10.10.0.0/20,   10.10.16.0/20, ...
  #   app:    10.10.64.0/20,  10.10.80.0/20, ...
  #   data:   10.10.128.0/20, 10.10.144.0/20, ...
  tier_offsets = { public = 0, app = 4, data = 8 }

  subnets = merge([
    for tier, offset in local.tier_offsets : {
      for i, az in local.azs : "${tier}-${az}" => {
        tier = tier
        az   = az
        cidr = cidrsubnet(var.vpc_cidr, 4, offset + i)
      }
    }
  ]...)

  # Which AZs get a NAT gateway.
  nat_azs = {
    none   = []
    single = [local.azs[0]]
    per_az = local.azs
  }[var.nat_gateway_mode]
}

resource "aws_vpc" "this" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = var.name
  }
}

resource "aws_default_security_group" "this" {
  vpc_id = aws_vpc.this.id

  tags = {
    Name = "${var.name}-default-deny"
  }
}

resource "aws_subnet" "this" {
  for_each = local.subnets

  vpc_id            = aws_vpc.this.id
  availability_zone = each.value.az
  cidr_block        = each.value.cidr

  tags = {
    Name = "${var.name}-${each.key}"
    Tier = each.value.tier
  }
}

# ------------------------------ public -------------------------------------

resource "aws_internet_gateway" "this" {
  vpc_id = aws_vpc.this.id

  tags = {
    Name = "${var.name}-igw"
  }
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.this.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.this.id
  }

  tags = {
    Name = "${var.name}-public"
  }
}

resource "aws_route_table_association" "public" {
  for_each = { for k, s in local.subnets : k => s if s.tier == "public" }

  subnet_id      = aws_subnet.this[each.key].id
  route_table_id = aws_route_table.public.id
}

# ------------------------------ NAT (optional) -----------------------------
# COST WARNING: each NAT gateway (and its Elastic IP) is billed per hour
# plus data processed. per_az multiplies that by the number of AZs.

resource "aws_eip" "nat" {
  for_each = toset(local.nat_azs)

  domain = "vpc"

  tags = {
    Name = "${var.name}-nat-${each.key}"
  }

  depends_on = [aws_internet_gateway.this]
}

resource "aws_nat_gateway" "this" {
  for_each = toset(local.nat_azs)

  allocation_id = aws_eip.nat[each.key].id
  subnet_id     = aws_subnet.this["public-${each.key}"].id

  tags = {
    Name = "${var.name}-nat-${each.key}"
  }

  depends_on = [aws_internet_gateway.this]
}

# ------------------------------ app tier -----------------------------------
# One route table per AZ so that, in per_az mode, each AZ uses its own
# NAT gateway and an AZ failure stays contained.

resource "aws_route_table" "app" {
  for_each = toset(local.azs)

  vpc_id = aws_vpc.this.id

  dynamic "route" {
    # Zero or one route block. In single mode every AZ uses the one NAT.
    for_each = var.nat_gateway_mode == "none" ? [] : [var.nat_gateway_mode == "per_az" ? each.key : local.azs[0]]

    content {
      cidr_block     = "0.0.0.0/0"
      nat_gateway_id = aws_nat_gateway.this[route.value].id
    }
  }

  tags = {
    Name = "${var.name}-app-${each.key}"
  }
}

resource "aws_route_table_association" "app" {
  for_each = toset(local.azs)

  subnet_id      = aws_subnet.this["app-${each.key}"].id
  route_table_id = aws_route_table.app[each.key].id
}

# ------------------------------ data tier ----------------------------------
# No 0.0.0.0/0 route at all: databases never need the internet.

resource "aws_route_table" "data" {
  vpc_id = aws_vpc.this.id

  tags = {
    Name = "${var.name}-data"
  }
}

resource "aws_route_table_association" "data" {
  for_each = { for k, s in local.subnets : k => s if s.tier == "data" }

  subnet_id      = aws_subnet.this[each.key].id
  route_table_id = aws_route_table.data.id
}
