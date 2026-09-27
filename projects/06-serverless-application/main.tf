# Architecture:
#   client → API Gateway (HTTP API) → Lambda → DynamoDB
#                  │                     │
#                  └── access logs       └── function logs  (CloudWatch)
#
# COST: every component here is billed per request / per use, so an
# idle stack costs very little. Check current pricing for each service.

# ------------------------------ data ---------------------------------------

resource "aws_dynamodb_table" "visits" {
  name         = "${var.name}-visits"
  billing_mode = "PAY_PER_REQUEST" # no capacity planning, pay per request
  hash_key     = "pk"

  attribute {
    name = "pk"
    type = "S"
  }

  server_side_encryption {
    enabled = true
  }

  point_in_time_recovery {
    enabled = true
  }
}

# ------------------------------ function -----------------------------------

data "archive_file" "app" {
  type        = "zip"
  source_dir  = "${path.module}/src"
  output_path = "${path.module}/build/app.zip"
}

resource "aws_cloudwatch_log_group" "function" {
  name              = "/aws/lambda/${var.name}-api"
  retention_in_days = var.log_retention_days
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

resource "aws_iam_role" "function" {
  name_prefix        = "${var.name}-api-"
  assume_role_policy = data.aws_iam_policy_document.lambda_trust.json
}

# Only the two things the function does: update one table, write its logs.
data "aws_iam_policy_document" "function" {
  statement {
    sid       = "UpdateVisits"
    actions   = ["dynamodb:UpdateItem"]
    resources = [aws_dynamodb_table.visits.arn]
  }

  statement {
    sid       = "WriteLogs"
    actions   = ["logs:CreateLogStream", "logs:PutLogEvents"]
    resources = ["${aws_cloudwatch_log_group.function.arn}:*"]
  }
}

resource "aws_iam_role_policy" "function" {
  name   = "api-permissions"
  role   = aws_iam_role.function.id
  policy = data.aws_iam_policy_document.function.json
}

resource "aws_lambda_function" "api" {
  function_name    = "${var.name}-api"
  role             = aws_iam_role.function.arn
  filename         = data.archive_file.app.output_path
  source_code_hash = data.archive_file.app.output_base64sha256
  runtime          = "python3.13"
  handler          = "app.handler"
  architectures    = ["arm64"]
  timeout          = 5

  environment {
    variables = {
      TABLE_NAME = aws_dynamodb_table.visits.name
    }
  }

  depends_on = [aws_cloudwatch_log_group.function, aws_iam_role_policy.function]
}

# ------------------------------ API ----------------------------------------

resource "aws_apigatewayv2_api" "http" {
  name          = "${var.name}-http"
  protocol_type = "HTTP"
}

# "AWS_PROXY" passes the whole HTTP request to Lambda as the event and
# returns the function's response as-is.
resource "aws_apigatewayv2_integration" "lambda" {
  api_id                 = aws_apigatewayv2_api.http.id
  integration_type       = "AWS_PROXY"
  integration_uri        = aws_lambda_function.api.invoke_arn
  payload_format_version = "2.0"
}

resource "aws_apigatewayv2_route" "any" {
  #checkov:skip=CKV_AWS_309:Public demo endpoint; stage throttling limits abuse. Real APIs add a JWT or IAM authorizer.
  api_id    = aws_apigatewayv2_api.http.id
  route_key = "GET /{proxy+}"
  target    = "integrations/${aws_apigatewayv2_integration.lambda.id}"
}

resource "aws_cloudwatch_log_group" "api_access" {
  name              = "/aws/apigateway/${var.name}-http"
  retention_in_days = var.log_retention_days
}

resource "aws_apigatewayv2_stage" "default" {
  api_id      = aws_apigatewayv2_api.http.id
  name        = "$default"
  auto_deploy = true

  # Protect the backend (and your bill) from bursts of traffic.
  default_route_settings {
    throttling_burst_limit = 20
    throttling_rate_limit  = 10
  }

  access_log_settings {
    destination_arn = aws_cloudwatch_log_group.api_access.arn
    format = jsonencode({
      requestId = "$context.requestId"
      ip        = "$context.identity.sourceIp"
      route     = "$context.routeKey"
      status    = "$context.status"
      latencyMs = "$context.responseLatency"
    })
  }
}

# Allow API Gateway (only this API) to invoke the function.
resource "aws_lambda_permission" "api" {
  statement_id  = "AllowHttpApiInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.api.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.http.execution_arn}/*/*"
}
