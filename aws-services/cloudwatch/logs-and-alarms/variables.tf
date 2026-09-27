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

variable "alert_email" {
  description = "Optional email address for alarm notifications. AWS sends a confirmation email first."
  type        = string
  default     = null
}

variable "log_retention_days" {
  description = "How long CloudWatch keeps log events. Unset retention = kept (and billed) forever."
  type        = number
  default     = 14
}
