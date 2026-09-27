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

variable "secret_name" {
  description = "Name of the secret."
  type        = string
  default     = "tf-learning/app/db-password"
}

variable "password_version" {
  description = "Increase this number to generate and store a NEW password (rotation by Terraform)."
  type        = number
  default     = 1
}
