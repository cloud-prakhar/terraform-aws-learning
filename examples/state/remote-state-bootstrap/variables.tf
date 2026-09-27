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

variable "state_bucket_prefix" {
  description = "Prefix for the state bucket name; AWS adds a unique suffix."
  type        = string
  default     = "tf-learning-state-"
}

variable "noncurrent_version_retention_days" {
  description = "How long to keep OLD versions of state files (your undo history)."
  type        = number
  default     = 90
}
