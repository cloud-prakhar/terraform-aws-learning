data "archive_file" "worker" {
  type        = "zip"
  source_dir  = "${path.module}/src"
  output_path = "${path.module}/build/worker.zip"
}

resource "aws_cloudwatch_log_group" "worker" {
  name              = "/aws/lambda/${var.name}-worker"
  retention_in_days = 14
}

data "aws_iam_policy_document" "lambda_trust" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "worker" {
  name_prefix        = "${var.name}-worker-"
  assume_role_policy = data.aws_iam_policy_document.lambda_trust.json
}

# The Lambda service polls the queue USING THE FUNCTION'S ROLE, so the
# role needs permission to receive and delete messages.
data "aws_iam_policy_document" "worker" {
  statement {
    sid = "ConsumeFulfilmentQueue"
    actions = [
      "sqs:ReceiveMessage",
      "sqs:DeleteMessage",
      "sqs:GetQueueAttributes",
    ]
    resources = [aws_sqs_queue.fulfilment.arn]
  }

  statement {
    sid       = "WriteLogs"
    actions   = ["logs:CreateLogStream", "logs:PutLogEvents"]
    resources = ["${aws_cloudwatch_log_group.worker.arn}:*"]
  }
}

resource "aws_iam_role_policy" "worker" {
  name   = "worker-permissions"
  role   = aws_iam_role.worker.id
  policy = data.aws_iam_policy_document.worker.json
}

resource "aws_lambda_function" "worker" {
  function_name    = "${var.name}-worker"
  role             = aws_iam_role.worker.arn
  filename         = data.archive_file.worker.output_path
  source_code_hash = data.archive_file.worker.output_base64sha256
  runtime          = "python3.13"
  handler          = "worker.handler"
  architectures    = ["arm64"]
  timeout          = 10

  depends_on = [aws_cloudwatch_log_group.worker]
}

# Event source mapping: Lambda polls SQS for us and invokes the function
# with batches of messages. Successfully processed messages are deleted.
resource "aws_lambda_event_source_mapping" "fulfilment" {
  event_source_arn = aws_sqs_queue.fulfilment.arn
  function_name    = aws_lambda_function.worker.arn
  batch_size       = 10

  # Only messages listed in batchItemFailures are retried.
  function_response_types = ["ReportBatchItemFailures"]

  depends_on = [aws_iam_role_policy.worker]
}
