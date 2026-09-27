output "queue_url" {
  description = "URL of the orders queue."
  value       = aws_sqs_queue.orders.url
}

output "bucket_name" {
  description = "Name of the uploads bucket."
  value       = aws_s3_bucket.uploads.bucket
}
