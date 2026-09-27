# This module does not create resources directly. It COMPOSES the other
# modules and wires their outputs into each other's inputs.

locals {
  name = "${var.name}-${var.environment}"
  tags = merge(var.tags, { Application = var.name, Environment = var.environment })

  instance_subnet_ids = var.instance_subnet_tier == "public" ? module.vpc.public_subnet_ids : module.vpc.private_subnet_ids

  http_rules = {
    for index, cidr in var.allowed_http_cidrs : "http-${index}" => {
      description = "HTTP from ${cidr}"
      port        = 80
      cidr_ipv4   = cidr
    }
  }
}

module "vpc" {
  source = "../vpc"

  name                   = local.name
  cidr_block             = var.vpc_cidr
  az_count               = var.az_count
  create_private_subnets = true
  enable_nat_gateway     = var.enable_nat_gateway
  tags                   = local.tags
}

module "artifacts_bucket" {
  source = "../s3"

  bucket_prefix = "${local.name}-artifacts-"
  force_destroy = var.environment != "prod"
  tags          = local.tags
}

# Least privilege: the instances may read THIS bucket and nothing else.
data "aws_iam_policy_document" "read_artifacts" {
  statement {
    sid       = "ListArtifactBucket"
    actions   = ["s3:ListBucket"]
    resources = [module.artifacts_bucket.bucket_arn]
  }

  statement {
    sid       = "ReadArtifacts"
    actions   = ["s3:GetObject"]
    resources = ["${module.artifacts_bucket.bucket_arn}/*"]
  }
}

module "instance_role" {
  source = "../iam"

  name                = "${local.name}-app"
  description         = "Role for ${local.name} application instances"
  trusted_services    = ["ec2.amazonaws.com"]
  managed_policy_arns = ["arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"]
  inline_policies = {
    "read-artifacts" = data.aws_iam_policy_document.read_artifacts.json
  }
  create_instance_profile = true
  tags                    = local.tags
}

module "app" {
  source = "../ec2"

  name                 = "${local.name}-app"
  vpc_id               = module.vpc.vpc_id
  subnet_ids           = local.instance_subnet_ids
  instance_count       = var.instance_count
  instance_type        = var.instance_type
  associate_public_ip  = var.instance_subnet_tier == "public"
  iam_instance_profile = module.instance_role.instance_profile_name
  ingress_rules        = local.http_rules
  tags                 = local.tags

  user_data = <<-EOT
    #!/bin/bash
    dnf install -y nginx
    echo "<h1>${local.name}</h1><p>Served by $(hostname -f)</p>" > /usr/share/nginx/html/index.html
    systemctl enable --now nginx
  EOT
}

# A check block reports a WARNING (it never blocks apply). Instances in
# private subnets without NAT cannot download packages or reach SSM.
check "private_instances_have_egress" {
  assert {
    condition     = var.instance_subnet_tier == "public" || var.enable_nat_gateway
    error_message = "Instances are in private subnets but enable_nat_gateway is false: they will have no internet access (no dnf, no SSM)."
  }
}
