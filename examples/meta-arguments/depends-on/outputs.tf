output "instance_id" {
  description = "ID of the instance that depends on the IAM policy."
  value       = aws_instance.app.id
}

output "config_bucket" {
  description = "Bucket the instance reads at boot."
  value       = aws_s3_bucket.config.bucket
}
