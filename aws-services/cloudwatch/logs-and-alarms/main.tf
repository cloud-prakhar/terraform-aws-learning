# COST: log ingestion and storage are billed per GB; each alarm has a
# monthly charge. This lab ingests almost nothing unless you write logs.

resource "aws_cloudwatch_log_group" "app" {
  name              = "/tf-learning/app"
  retention_in_days = var.log_retention_days
}

# A metric filter turns log lines into numbers: every log event that
# contains the word ERROR adds 1 to the custom metric AppErrors.
resource "aws_cloudwatch_log_metric_filter" "errors" {
  name           = "app-errors"
  log_group_name = aws_cloudwatch_log_group.app.name
  pattern        = "ERROR"

  metric_transformation {
    name          = "AppErrors"
    namespace     = "TfLearning/App"
    value         = "1"
    default_value = "0"
  }
}

# Where alarms send notifications.
resource "aws_sns_topic" "alerts" {
  name = "tf-learning-alerts"
}

resource "aws_sns_topic_subscription" "email" {
  count = var.alert_email == null ? 0 : 1

  topic_arn = aws_sns_topic.alerts.arn
  protocol  = "email"
  endpoint  = var.alert_email
}

resource "aws_cloudwatch_metric_alarm" "errors" {
  alarm_name        = "tf-learning-app-errors"
  alarm_description = "More than 5 ERROR log lines within 5 minutes"

  namespace   = "TfLearning/App"
  metric_name = "AppErrors"
  statistic   = "Sum"
  period      = 300
  threshold   = 5

  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  treat_missing_data  = "notBreaching" # no logs = no errors

  alarm_actions = [aws_sns_topic.alerts.arn]
  ok_actions    = [aws_sns_topic.alerts.arn]
}
