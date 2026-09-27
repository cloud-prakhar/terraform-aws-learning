output "function_name" {
  description = "Name of the Lambda function."
  value       = aws_lambda_function.this.function_name
}

output "log_group" {
  description = "Where the function's logs go."
  value       = aws_cloudwatch_log_group.function.name
}

output "invoke_command" {
  description = "Invoke the function manually from the CLI."
  value       = "aws lambda invoke --function-name ${aws_lambda_function.this.function_name} --region ${var.aws_region} response.json && cat response.json"
}
