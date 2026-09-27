output "workspace" {
  description = "Workspace these resources belong to."
  value       = terraform.workspace
}

output "queue_url" {
  description = "Queue URL for this workspace."
  value       = aws_sqs_queue.events.url
}

output "bucket_name" {
  description = "Bucket name for this workspace."
  value       = aws_s3_bucket.data.bucket
}
