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

variable "name" {
  description = "Name prefix for networking resources."
  type        = string
  default     = "tf-learning"
}

variable "vpc_cidr" {
  description = "IPv4 range for the whole VPC. 10.0.0.0/16 = 65,536 private addresses."
  type        = string
  default     = "10.0.0.0/16"
}
