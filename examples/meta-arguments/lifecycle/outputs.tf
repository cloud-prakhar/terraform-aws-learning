output "security_group_id" {
  description = "Current security group ID (changes after a replacement)."
  value       = aws_security_group.app.id
}

output "instance_id" {
  description = "Instance ID (changes when app_version changes)."
  value       = aws_instance.app.id
}

output "bucket_name" {
  description = "Bucket used for the prevent_destroy exercise."
  value       = aws_s3_bucket.important.bucket
}
