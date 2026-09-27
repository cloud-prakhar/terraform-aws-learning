output "topic_arn" {
  description = "Publish order events here."
  value       = aws_sns_topic.orders.arn
}

output "queue_urls" {
  description = "Queue URLs: fulfilment, audit and the DLQ."
  value = {
    fulfilment     = aws_sqs_queue.fulfilment.url
    fulfilment_dlq = aws_sqs_queue.fulfilment_dlq.url
    audit          = aws_sqs_queue.audit.url
  }
}

output "worker_log_group" {
  description = "Log group of the worker function."
  value       = aws_cloudwatch_log_group.worker.name
}
