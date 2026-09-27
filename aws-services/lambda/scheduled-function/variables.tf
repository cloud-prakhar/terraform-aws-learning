variable "aws_region" {
  description = "AWS Region to deploy into."
  type        = string
  default     = "us-east-1"
}

variable "aws_profile" {
  description = "Named AWS CLI profile to use. Leave null to use the default credential chain."
  type        = string
  default     = null
}

variable "function_name" {
  description = "Name of the Lambda function."
  type        = string
  default     = "tf-learning-heartbeat"
}

variable "schedule_expression" {
  description = "How often EventBridge invokes the function."
  type        = string
  default     = "rate(1 hour)"
}

variable "greeting" {
  description = "Passed to the function as an environment variable."
  type        = string
  default     = "Hello from Terraform"
}
