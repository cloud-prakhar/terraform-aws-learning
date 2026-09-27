output "count_queue_urls" {
  description = "Queue URLs created with count (a list)."
  value       = aws_sqs_queue.by_count[*].url
}

output "for_each_queue_urls" {
  description = "Queue URLs created with for_each (a map keyed by name)."
  value       = { for name, q in aws_sqs_queue.by_key : name => q.url }
}
