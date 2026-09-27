# Region is hard-coded here to keep the first lab tiny.
# Chapter 07 replaces it with an input variable.
provider "aws" {
  region = "us-east-1"
}

resource "aws_s3_bucket" "first" {
  # Bucket names are global across ALL AWS accounts. bucket_prefix lets
  # AWS append a unique suffix so your apply does not collide with
  # another learner's bucket.
  bucket_prefix = "tf-learning-first-"

  tags = {
    Name      = "my-first-terraform-bucket"
    ManagedBy = "Terraform"
  }
}

output "bucket_name" {
  description = "The name AWS generated for the bucket."
  value       = aws_s3_bucket.first.bucket
}
