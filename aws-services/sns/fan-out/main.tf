# One message published to the topic is delivered to EVERY subscribed
# queue: that is fan-out. Each consumer processes its copy independently.

resource "aws_sns_topic" "orders" {
  name = "tf-learning-order-events"

  # Encrypt messages at rest with the AWS managed key for SNS.
  # Note: some AWS services (e.g. CloudWatch alarms) cannot publish to a
  # topic encrypted with the AWS managed key; they need a customer
  # managed key whose policy allows them.
  kms_master_key_id = "alias/aws/sns"
}

locals {
  consumers = ["billing", "shipping"]
}

resource "aws_sqs_queue" "consumer" {
  for_each = toset(local.consumers)

  name                    = "tf-learning-${each.key}"
  sqs_managed_sse_enabled = true
}

# SNS needs permission to write into each queue. The SourceArn condition
# means ONLY this topic may send, not any SNS topic in any account.
data "aws_iam_policy_document" "allow_topic" {
  for_each = aws_sqs_queue.consumer

  statement {
    actions   = ["sqs:SendMessage"]
    resources = [each.value.arn]

    principals {
      type        = "Service"
      identifiers = ["sns.amazonaws.com"]
    }

    condition {
      test     = "ArnEquals"
      variable = "aws:SourceArn"
      values   = [aws_sns_topic.orders.arn]
    }
  }
}

resource "aws_sqs_queue_policy" "allow_topic" {
  for_each = aws_sqs_queue.consumer

  queue_url = each.value.id
  policy    = data.aws_iam_policy_document.allow_topic[each.key].json
}

resource "aws_sns_topic_subscription" "consumer" {
  for_each = aws_sqs_queue.consumer

  topic_arn = aws_sns_topic.orders.arn
  protocol  = "sqs"
  endpoint  = each.value.arn

  # Deliver the original message body instead of an SNS JSON envelope.
  raw_message_delivery = true

  # Shipping only cares about paid orders. Billing gets everything.
  filter_policy = each.key == "shipping" ? jsonencode({ status = ["paid"] }) : null

  depends_on = [aws_sqs_queue_policy.allow_topic]
}
