output "bucket_id" {
  description = "Name of the bucket (for S3 the ID and the name are the same)."
  value       = aws_s3_bucket.this.id
}

output "bucket_arn" {
  description = "ARN of the bucket, for IAM policies."
  value       = aws_s3_bucket.this.arn
}

output "bucket_regional_domain_name" {
  description = "Regional domain name, e.g. for a CloudFront origin."
  value       = aws_s3_bucket.this.bucket_regional_domain_name
}
