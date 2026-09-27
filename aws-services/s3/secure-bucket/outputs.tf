output "bucket_name" {
  description = "Bucket name."
  value       = aws_s3_bucket.this.bucket
}

output "bucket_arn" {
  description = "Bucket ARN."
  value       = aws_s3_bucket.this.arn
}

output "object_uri" {
  description = "S3 URI of the demo object."
  value       = "s3://${aws_s3_bucket.this.bucket}/${aws_s3_object.readme.key}"
}
