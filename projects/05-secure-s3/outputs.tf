output "data_bucket" {
  description = "KMS-encrypted, versioned data bucket."
  value       = aws_s3_bucket.data.bucket
}

output "log_bucket" {
  description = "Bucket receiving S3 server access logs."
  value       = aws_s3_bucket.logs.bucket
}

output "kms_key_alias" {
  description = "Alias of the bucket's KMS key."
  value       = aws_kms_alias.data.name
}

output "writer_role_arn" {
  description = "Assume this role to upload."
  value       = aws_iam_role.writer.arn
}

output "reader_role_arn" {
  description = "Assume this role to download."
  value       = aws_iam_role.reader.arn
}
