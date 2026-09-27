output "state_bucket" {
  description = "Bucket for environment state. Save as the TF_STATE_BUCKET repository variable."
  value       = module.state_bucket.bucket_id
}

output "plan_role_arn" {
  description = "Save as the AWS_PLAN_ROLE_ARN repository variable."
  value       = aws_iam_role.plan.arn
}

output "apply_role_arns" {
  description = "Save each as the AWS_APPLY_ROLE_ARN variable of the matching GitHub Environment."
  value       = { for env, role in aws_iam_role.apply : env => role.arn }
}
