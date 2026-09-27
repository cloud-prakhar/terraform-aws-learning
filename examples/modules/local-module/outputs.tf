output "logs_bucket" {
  description = "Bucket created by the single module call."
  value       = module.logs_bucket.bucket_id
}

output "buckets" {
  description = "Buckets created by the for_each module call."
  value       = { for name, m in module.bucket : name => m.bucket_id }
}
