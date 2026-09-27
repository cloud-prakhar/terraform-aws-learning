# SQS standard queues have a monthly free request allowance and no
# charge while idle; check current SQS pricing for your account.

# Dead-letter queue (DLQ): where messages go after failing too often,
# so one "poison" message cannot block or loop forever.
resource "aws_sqs_queue" "orders_dlq" {
  name = "tf-learning-orders-dlq"

  # Keep failed messages as long as SQS allows (14 days) for debugging.
  message_retention_seconds = 1209600
  sqs_managed_sse_enabled   = true
}

resource "aws_sqs_queue" "orders" {
  name = "tf-learning-orders"

  # While a consumer processes a message, it is hidden from other
  # consumers for this long. Set it longer than your worst-case
  # processing time, or the message is delivered twice.
  visibility_timeout_seconds = 60

  # How long an unprocessed message is kept (here: 4 days).
  message_retention_seconds = 345600

  # Long polling: consumers wait up to 20 s for messages instead of
  # returning empty immediately. Fewer empty responses = fewer requests.
  receive_wait_time_seconds = 20

  # Encryption at rest with SQS-owned keys (no KMS charges).
  sqs_managed_sse_enabled = true

  # After 3 failed receives, move the message to the DLQ.
  redrive_policy = jsonencode({
    deadLetterTargetArn = aws_sqs_queue.orders_dlq.arn
    maxReceiveCount     = 3
  })
}

# The DLQ only accepts messages redriven from the orders queue.
resource "aws_sqs_queue_redrive_allow_policy" "orders_dlq" {
  queue_url = aws_sqs_queue.orders_dlq.id

  redrive_allow_policy = jsonencode({
    redrivePermission = "byQueue"
    sourceQueueArns   = [aws_sqs_queue.orders.arn]
  })
}
