# Data sources READ information. They never create, change or delete anything.

# Who am I? Useful for building ARNs and globally unique names.
data "aws_caller_identity" "current" {}

# Which Region is the provider configured for?
data "aws_region" "current" {}

# Which Availability Zones can I use right now in this Region?
data "aws_availability_zones" "available" {
  state = "available"
}

# Latest Ubuntu 24.04 LTS image published by Canonical.
# 099720109477 is Canonical's official AWS account ID. Always pin the
# owner: anyone can publish an AMI with a convincing name.
data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"]

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd-gp3/ubuntu-noble-24.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# The default VPC that AWS creates in every Region (unless someone deleted it).
data "aws_vpc" "default" {
  default = true
}

# All subnets that belong to that VPC.
data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

# Details of one specific subnet, looked up by ID.
data "aws_subnet" "first" {
  id = data.aws_subnets.default.ids[0]
}

# Optional lookup of an existing secret's METADATA (name, ARN, KMS key).
# We deliberately do not read the secret value here: anything Terraform
# reads through a data source is written to the state file.
data "aws_secretsmanager_secret" "existing" {
  count = var.existing_secret_name == null ? 0 : 1
  name  = var.existing_secret_name
}
