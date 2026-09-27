output "queue_url" {
  description = "URL of the orders queue: what SDKs and the CLI use to send/receive."
  value       = aws_sqs_queue.orders.url
}

output "queue_arn" {
  description = "ARN of the orders queue: what IAM policies and event sources use."
  value       = aws_sqs_queue.orders.arn
}

output "dlq_url" {
  description = "URL of the dead-letter queue."
  value       = aws_sqs_queue.orders_dlq.url
}
