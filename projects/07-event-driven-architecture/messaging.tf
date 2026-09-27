# Architecture:
#
#   publisher ──► SNS topic "orders" ──┬──► SQS "fulfilment" ──► Lambda worker
#                                      │          │ (after N failures)
#                                      │          └──► SQS "fulfilment-dlq"
#                                      └──► SQS "audit" (kept for later analysis)
#
# COST: SNS, SQS and Lambda are billed per request; idle cost is minimal.

resource "aws_sns_topic" "orders" {
  name              = "${var.name}-orders"
  kms_master_key_id = "alias/aws/sns"
}

# ------------------------------ queues -------------------------------------

resource "aws_sqs_queue" "fulfilment_dlq" {
  name                      = "${var.name}-fulfilment-dlq"
  message_retention_seconds = 1209600
  sqs_managed_sse_enabled   = true
}

resource "aws_sqs_queue" "fulfilment" {
  name                    = "${var.name}-fulfilment"
  sqs_managed_sse_enabled = true

  # AWS recommends at least 6x the function timeout, so a message is not
  # re-delivered while Lambda is still retrying/processing it.
  visibility_timeout_seconds = aws_lambda_function.worker.timeout * 6

  redrive_policy = jsonencode({
    deadLetterTargetArn = aws_sqs_queue.fulfilment_dlq.arn
    maxReceiveCount     = var.max_receive_count
  })
}

resource "aws_sqs_queue" "audit" {
  name                      = "${var.name}-audit"
  message_retention_seconds = 1209600
  sqs_managed_sse_enabled   = true
}

locals {
  subscribers = {
    fulfilment = aws_sqs_queue.fulfilment
    audit      = aws_sqs_queue.audit
  }
}

data "aws_iam_policy_document" "sns_to_sqs" {
  for_each = local.subscribers

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

resource "aws_sqs_queue_policy" "sns_to_sqs" {
  for_each = local.subscribers

  queue_url = each.value.id
  policy    = data.aws_iam_policy_document.sns_to_sqs[each.key].json
}

resource "aws_sns_topic_subscription" "queues" {
  for_each = local.subscribers

  topic_arn            = aws_sns_topic.orders.arn
  protocol             = "sqs"
  endpoint             = each.value.arn
  raw_message_delivery = true

  depends_on = [aws_sqs_queue_policy.sns_to_sqs]
}
