# Reuses the VPC module built in Chapter 13.
# Instances run in PRIVATE subnets. They do not need a NAT gateway,
# because the web server is Python's built-in HTTP server (nothing to
# download). The trade-off: no internet access, so no SSM either.
module "vpc" {
  source = "../../modules/vpc"

  name                   = var.name
  cidr_block             = "10.80.0.0/16"
  az_count               = 2
  create_private_subnets = true
  enable_nat_gateway     = false
}

resource "aws_security_group" "alb" {
  name_prefix = "${var.name}-alb-"
  description = "Public HTTP to the load balancer"
  vpc_id      = module.vpc.vpc_id

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_security_group" "web" {
  name_prefix = "${var.name}-web-"
  description = "HTTP from the load balancer only"
  vpc_id      = module.vpc.vpc_id

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_vpc_security_group_ingress_rule" "alb_http" {
  #checkov:skip=CKV_AWS_260:Public load balancer.
  security_group_id = aws_security_group.alb.id
  description       = "HTTP from the internet"
  ip_protocol       = "tcp"
  from_port         = 80
  to_port           = 80
  cidr_ipv4         = "0.0.0.0/0"
}

resource "aws_vpc_security_group_egress_rule" "alb_to_web" {
  security_group_id            = aws_security_group.alb.id
  description                  = "Forward requests and health checks to instances"
  ip_protocol                  = "tcp"
  from_port                    = 80
  to_port                      = 80
  referenced_security_group_id = aws_security_group.web.id
}

resource "aws_vpc_security_group_ingress_rule" "web_from_alb" {
  #checkov:skip=CKV_AWS_260:False positive - the source is the ALB security group, not 0.0.0.0/0.
  security_group_id            = aws_security_group.web.id
  description                  = "HTTP from the load balancer"
  ip_protocol                  = "tcp"
  from_port                    = 80
  to_port                      = 80
  referenced_security_group_id = aws_security_group.alb.id
}
