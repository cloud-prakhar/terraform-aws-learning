output "key_arn" {
  description = "ARN of the KMS key."
  value       = aws_kms_key.data.arn
}

output "alias" {
  description = "Alias pointing to the key."
  value       = aws_kms_alias.data.name
}

output "bucket_name" {
  description = "Bucket encrypted with the key."
  value       = aws_s3_bucket.encrypted.bucket
}
