# An EC2 role that can be managed through SSM Session Manager.
#   terraform init && terraform plan

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

module "ec2_role" {
  source = "../.."

  name                    = "tf-learning-iam-module-demo"
  description             = "Demo EC2 role with SSM access"
  trusted_services        = ["ec2.amazonaws.com"]
  managed_policy_arns     = ["arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"]
  create_instance_profile = true
}

output "role_arn" {
  description = "ARN of the created role."
  value       = module.ec2_role.role_arn
}

output "instance_profile_name" {
  description = "Instance profile to attach to EC2 instances."
  value       = module.ec2_role.instance_profile_name
}
