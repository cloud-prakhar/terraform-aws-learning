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

variable "instance_count" {
  description = "How many identical worker instances to create with count."
  type        = number
  default     = 2

  validation {
    condition     = var.instance_count >= 0 && var.instance_count <= 3
    error_message = "Keep instance_count between 0 and 3 in this lab to limit cost."
  }
}

variable "buckets" {
  description = "Buckets to create with for_each. Key = logical name, value = settings."
  type = map(object({
    versioning = bool
  }))
  default = {
    logs      = { versioning = false }
    artifacts = { versioning = true }
    backups   = { versioning = true }
  }
}
