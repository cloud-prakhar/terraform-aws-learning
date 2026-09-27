output "vpc_id" {
  description = "VPC of this environment."
  value       = module.app.vpc_id
}

output "instance_ids" {
  description = "Application instances."
  value       = module.app.instance_ids
}

output "artifacts_bucket" {
  description = "Artifacts bucket of this environment."
  value       = module.app.artifacts_bucket
}
