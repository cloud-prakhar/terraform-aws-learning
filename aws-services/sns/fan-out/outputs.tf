output "topic_arn" {
  description = "Publish messages here."
  value       = aws_sns_topic.orders.arn
}

output "queue_urls" {
  description = "Queue URL per consumer."
  value       = { for name, q in aws_sqs_queue.consumer : name => q.url }
}
