output "imported_bucket_arn" {
  description = "ARN of the bucket now managed by Terraform."
  value       = aws_s3_bucket.legacy.arn
}
