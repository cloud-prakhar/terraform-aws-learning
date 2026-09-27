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

variable "queue_names" {
  description = "Queue names. The README asks you to remove the middle one and compare plans."
  type        = list(string)
  default     = ["orders", "payments", "emails"]
}
