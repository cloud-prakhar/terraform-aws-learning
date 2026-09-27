# A module from the public Terraform Registry:
#   https://registry.terraform.io/modules/terraform-aws-modules/vpc/aws
# Always pin a version. "~> 6.7" = 6.7 or any newer 6.x, never 7.0.
# Read the module's README and inputs before using it.
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 6.7"

  name = "tf-learning-registry-vpc"
  cidr = "10.30.0.0/16"

  azs             = ["${var.aws_region}a", "${var.aws_region}b"]
  public_subnets  = ["10.30.0.0/24", "10.30.1.0/24"]
  private_subnets = ["10.30.10.0/24", "10.30.11.0/24"]

  # NAT gateways cost money every hour; off for this lab.
  enable_nat_gateway = false
}
