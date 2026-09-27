# Uses the default (un-aliased) provider → var.aws_region.
resource "aws_s3_bucket" "primary" {
  bucket_prefix = "tf-learning-primary-"
  force_destroy = true
}

# `provider` meta-argument: pick a non-default provider configuration.
resource "aws_s3_bucket" "secondary" {
  provider = aws.secondary

  bucket_prefix = "tf-learning-secondary-"
  force_destroy = true
}

# `providers` meta-argument: hand a provider configuration to a module.
# Inside the module, every resource uses "aws" – here that means
# aws.secondary. The module itself never needs to know about Regions.
module "replica_bucket" {
  source = "../../../modules/s3"

  providers = {
    aws = aws.secondary
  }

  bucket_prefix = "tf-learning-module-secondary-"
  force_destroy = true
}
