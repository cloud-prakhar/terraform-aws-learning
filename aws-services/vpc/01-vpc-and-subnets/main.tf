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

# At this step "public" and "private" are just names: no subnet can
# reach the internet yet because nothing routes to an internet gateway.
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
