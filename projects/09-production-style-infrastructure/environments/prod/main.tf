# PROD: private instances behind a NAT gateway, two instances across AZs.
# COST WARNING: NAT gateway + 2 instances run 24/7 once applied.
module "app" {
  source = "../../../../modules/application-stack"

  name        = "shop"
  environment = "prod"

  vpc_cidr             = "10.91.0.0/16"
  az_count             = 2
  enable_nat_gateway   = true
  instance_subnet_tier = "private"
  instance_count       = 2
  instance_type        = "t3.small"
  allowed_http_cidrs   = []
}
