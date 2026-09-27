# DEV: cheapest shape that still exercises the whole stack.
# Environment differences live HERE as plain values, so a code review
# shows exactly how dev and prod differ.
module "app" {
  source = "../../../../modules/application-stack"

  name        = "shop"
  environment = "dev"

  vpc_cidr             = "10.90.0.0/16"
  az_count             = 2
  enable_nat_gateway   = false    # no hourly NAT charge in dev
  instance_subnet_tier = "public" # public IP instead of NAT
  instance_count       = 1
  instance_type        = "t3.micro"
  allowed_http_cidrs   = []
}
