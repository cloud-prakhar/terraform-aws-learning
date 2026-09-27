# The smallest useful stack: 2-AZ VPC, 1 instance in a public subnet,
# artifacts bucket, least-privilege instance role. No NAT gateway.
#   terraform init && terraform plan
#
# COST: one t3.micro + one public IPv4 address while it runs.

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

module "stack" {
  source = "../.."

  name        = "demo"
  environment = "dev"
}

output "instance_ids" {
  description = "Instances created by the stack."
  value       = module.stack.instance_ids
}
