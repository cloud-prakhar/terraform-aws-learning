output "role_arn" {
  description = "ARN of the application role."
  value       = aws_iam_role.app.arn
}

output "instance_profile_name" {
  description = "Instance profile to set as iam_instance_profile on aws_instance."
  value       = aws_iam_instance_profile.app.name
}

output "policy_arn" {
  description = "ARN of the customer managed policy."
  value       = aws_iam_policy.read_config.arn
}

output "config_bucket" {
  description = "Bucket the role can read under config/."
  value       = aws_s3_bucket.app_config.bucket
}
