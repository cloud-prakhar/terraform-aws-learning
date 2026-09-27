# Minimal usage of the s3 module. Run from this directory:
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

module "bucket" {
  source = "../.."

  bucket_prefix = "tf-learning-module-demo-"
  force_destroy = true # demo only: lets `terraform destroy` empty the bucket

  tags = {
    Example = "modules/s3/examples/basic"
  }
}

output "bucket_name" {
  description = "Name of the bucket created by the module."
  value       = module.bucket.bucket_id
}
