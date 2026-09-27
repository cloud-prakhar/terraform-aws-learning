output "vpc_id" {
  description = "ID of the application VPC."
  value       = module.vpc.vpc_id
}

output "public_subnet_ids" {
  description = "Public subnet IDs."
  value       = module.vpc.public_subnet_ids
}

output "private_subnet_ids" {
  description = "Private subnet IDs."
  value       = module.vpc.private_subnet_ids
}

output "artifacts_bucket" {
  description = "Name of the artifacts bucket the instances can read."
  value       = module.artifacts_bucket.bucket_id
}

output "instance_ids" {
  description = "Map of instance name => ID."
  value       = module.app.instance_ids
}

output "instance_public_ips" {
  description = "Map of instance name => public IP (empty in private subnets)."
  value       = module.app.public_ips
}

output "instance_role_arn" {
  description = "ARN of the instances' IAM role."
  value       = module.instance_role.role_arn
}
