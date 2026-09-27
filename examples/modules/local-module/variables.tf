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

variable "buckets" {
  description = "Buckets to create through the module: logical name => versioning on/off."
  type        = map(bool)
  default = {
    reports = true
    scratch = false
  }
}
