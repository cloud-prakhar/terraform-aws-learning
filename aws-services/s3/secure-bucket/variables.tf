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

variable "bucket_prefix" {
  description = "Prefix for the bucket name; AWS appends a unique suffix."
  type        = string
  default     = "tf-learning-s3-lab-"
}

variable "log_retention_days" {
  description = "Delete objects under logs/ after this many days."
  type        = number
  default     = 365
}
