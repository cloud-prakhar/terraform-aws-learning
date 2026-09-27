# One instance in the default VPC, reachable only through SSM (no SSH).
#   terraform init && terraform plan
#
# COST: creates a t3.micro instance. Run `terraform destroy` when done.

terraform {
  required_version = ">= 1.11.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

data "aws_vpc" "default" {
  default = true
}

data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

module "ec2" {
  source = "../.."

  name       = "tf-learning-ec2-demo"
  vpc_id     = data.aws_vpc.default.id
  subnet_ids = data.aws_subnets.default.ids
}

output "instance_ids" {
  description = "Instances created by the module."
  value       = module.ec2.instance_ids
}
