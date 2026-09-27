output "log_group_name" {
  description = "Log group to write test events into."
  value       = aws_cloudwatch_log_group.app.name
}

output "alarm_name" {
  description = "Name of the error alarm."
  value       = aws_cloudwatch_metric_alarm.errors.alarm_name
}

output "alerts_topic_arn" {
  description = "SNS topic that receives alarm notifications."
  value       = aws_sns_topic.alerts.arn
}
