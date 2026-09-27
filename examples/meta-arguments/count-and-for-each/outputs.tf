output "worker_ids" {
  description = "List of worker instance IDs (count → list, via splat)."
  value       = aws_instance.worker[*].id
}

output "bucket_names" {
  description = "Map of logical name => bucket name (for_each → map)."
  value       = { for key, bucket in aws_s3_bucket.this : key => bucket.bucket }
}
