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

variable "zone_name" {
  description = "Private DNS domain, resolvable only inside the associated VPC."
  type        = string
  default     = "tf-learning.internal"
}
