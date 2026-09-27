# COST: Lambda, EventBridge and CloudWatch Logs are billed per use.
# One invocation per hour is tiny, but check current pricing.

# --- Package: zip the source directory -----------------------------------
# archive_file runs during plan. When handler.py changes, the zip hash
# changes and Terraform uploads a new version of the code.
data "archive_file" "function" {
  type        = "zip"
  source_dir  = "${path.module}/src"
  output_path = "${path.module}/build/function.zip"
}

# --- Logs: create the log group ourselves --------------------------------
# If Lambda creates it on first run, Terraform does not manage it: it
# never expires and is left behind on destroy.
resource "aws_cloudwatch_log_group" "function" {
  name              = "/aws/lambda/${var.function_name}"
  retention_in_days = 14
}

# --- Execution role: what the FUNCTION may do ----------------------------

data "aws_iam_policy_document" "lambda_trust" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "function" {
  name_prefix        = "tf-learning-lambda-"
  assume_role_policy = data.aws_iam_policy_document.lambda_trust.json
}

# Least privilege: write to THIS log group only. (The AWS managed policy
# AWSLambdaBasicExecutionRole allows writing to any log group.)
data "aws_iam_policy_document" "logs" {
  statement {
    actions   = ["logs:CreateLogStream", "logs:PutLogEvents"]
    resources = ["${aws_cloudwatch_log_group.function.arn}:*"]
  }
}

resource "aws_iam_role_policy" "logs" {
  name   = "write-own-logs"
  role   = aws_iam_role.function.id
  policy = data.aws_iam_policy_document.logs.json
}

# --- The function ----------------------------------------------------------

resource "aws_lambda_function" "this" {
  function_name = var.function_name
  role          = aws_iam_role.function.arn

  filename         = data.archive_file.function.output_path
  source_code_hash = data.archive_file.function.output_base64sha256

  runtime       = "python3.13"
  handler       = "handler.handler" # file name . function name
  architectures = ["arm64"]         # Graviton: lower price per GB-second
  memory_size   = 128
  timeout       = 10

  environment {
    variables = {
      GREETING = var.greeting
    }
  }

  # The log group and permissions must exist before the first invocation.
  depends_on = [aws_cloudwatch_log_group.function, aws_iam_role_policy.logs]
}

# --- Trigger: EventBridge schedule -----------------------------------------

resource "aws_cloudwatch_event_rule" "schedule" {
  name                = "${var.function_name}-schedule"
  schedule_expression = var.schedule_expression
}

resource "aws_cloudwatch_event_target" "function" {
  rule = aws_cloudwatch_event_rule.schedule.name
  arn  = aws_lambda_function.this.arn
}

# A RESOURCE-BASED policy on the function: allows EventBridge (and only
# this rule) to invoke it. The execution role above is the opposite
# direction: what the function may call.
resource "aws_lambda_permission" "eventbridge" {
  statement_id  = "AllowEventBridgeInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.this.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.schedule.arn
}
