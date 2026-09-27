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
  description = "Name prefix for all resources."
  type        = string
  default     = "tf-learning-p07"
}

variable "max_receive_count" {
  description = "Failed processing attempts before a message moves to the dead-letter queue."
  type        = number
  default     = 3
}
