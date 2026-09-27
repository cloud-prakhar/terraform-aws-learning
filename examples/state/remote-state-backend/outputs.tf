output "queue_url" {
  description = "URL of the queue tracked in remote state."
  value       = aws_sqs_queue.jobs.url
}
