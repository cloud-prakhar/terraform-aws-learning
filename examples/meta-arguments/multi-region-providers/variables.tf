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

variable "secondary_region" {
  description = "Second Region used by the aliased provider."
  type        = string
  default     = "us-west-2"
}
