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

variable "existing_bucket_name" {
  description = "Name of a bucket that ALREADY exists in your account (created outside Terraform)."
  type        = string
}
