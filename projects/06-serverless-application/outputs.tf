output "api_url" {
  description = "Base URL of the HTTP API. Try: curl <api_url>/hello"
  value       = aws_apigatewayv2_stage.default.invoke_url
}

output "table_name" {
  description = "DynamoDB table storing visit counters."
  value       = aws_dynamodb_table.visits.name
}

output "function_log_group" {
  description = "CloudWatch log group of the function."
  value       = aws_cloudwatch_log_group.function.name
}
