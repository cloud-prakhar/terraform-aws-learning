output "vpc_id" {
  description = "VPC created by the registry module."
  value       = module.vpc.vpc_id
}

output "public_subnets" {
  description = "Public subnet IDs from the registry module."
  value       = module.vpc.public_subnets
}

output "private_subnets" {
  description = "Private subnet IDs from the registry module."
  value       = module.vpc.private_subnets
}
