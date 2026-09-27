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

variable "app_version" {
  description = "Pretend application version. Changing it forces the instance to be replaced (replace_triggered_by)."
  type        = string
  default     = "1.0.0"
}
