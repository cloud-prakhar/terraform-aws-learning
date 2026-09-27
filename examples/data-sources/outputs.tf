output "account_id" {
  description = "AWS account Terraform is authenticated to."
  value       = local.account_id
}

output "caller_arn" {
  description = "IAM identity (user or role) Terraform is using."
  value       = data.aws_caller_identity.current.arn
}

output "region" {
  description = "Region of the configured provider."
  value       = local.region
}

output "availability_zones" {
  description = "The first two available AZs."
  value       = local.azs
}

output "ubuntu_ami" {
  description = "ID and name of the newest Ubuntu 24.04 AMI."
  value = {
    id   = data.aws_ami.ubuntu.id
    name = data.aws_ami.ubuntu.name
  }
}

output "default_vpc" {
  description = "Default VPC ID and CIDR block."
  value = {
    id   = data.aws_vpc.default.id
    cidr = data.aws_vpc.default.cidr_block
  }
}

output "default_subnet_ids" {
  description = "Subnets in the default VPC."
  value       = data.aws_subnets.default.ids
}

output "first_subnet_az" {
  description = "AZ of the first default subnet (from the aws_subnet data source)."
  value       = data.aws_subnet.first.availability_zone
}

output "existing_secret_arn" {
  description = "ARN of the looked-up secret, or null when no name was given."
  value       = one(data.aws_secretsmanager_secret.existing[*].arn)
}

output "bucket_name" {
  description = "Bucket whose name was built from data-source values."
  value       = aws_s3_bucket.reports.bucket
}
