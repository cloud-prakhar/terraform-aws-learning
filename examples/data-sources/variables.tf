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

variable "project_name" {
  description = "Short project name used in names and tags."
  type        = string
  default     = "tf-learning"
}

variable "environment" {
  description = "Environment name."
  type        = string
  default     = "dev"
}

variable "existing_secret_name" {
  description = "Optional: name of an EXISTING Secrets Manager secret to look up. Leave null to skip the lookup."
  type        = string
  default     = null
}
