output "primary_bucket" {
  description = "Bucket in the primary Region and the Region it lives in."
  value       = "${aws_s3_bucket.primary.bucket} (${aws_s3_bucket.primary.bucket_region})"
}

output "secondary_bucket" {
  description = "Bucket created through the aliased provider."
  value       = "${aws_s3_bucket.secondary.bucket} (${aws_s3_bucket.secondary.bucket_region})"
}

output "module_bucket" {
  description = "Bucket created by a module that received aws.secondary."
  value       = module.replica_bucket.bucket_id
}
