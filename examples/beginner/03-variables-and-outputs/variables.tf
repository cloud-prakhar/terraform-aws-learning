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

variable "project_name" {
  description = "Short project name used in resource names and tags."
  type        = string
  default     = "tf-learning"

  validation {
    # S3 bucket prefixes allow lowercase letters, numbers and hyphens.
    condition     = can(regex("^[a-z0-9-]{3,20}$", var.project_name))
    error_message = "project_name must be 3-20 characters of lowercase letters, numbers or hyphens."
  }
}

variable "environment" {
  description = "Environment name (dev, staging or prod)."
  type        = string
  default     = "dev"

  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "environment must be dev, staging or prod."
  }
}

variable "instance_type" {
  description = "EC2 instance type. Small x86_64 burstable types only (the AMI lookup is x86_64)."
  type        = string
  default     = "t3.micro"

  validation {
    condition     = contains(["t3.micro", "t3.small", "t3a.micro", "t3a.small"], var.instance_type)
    error_message = "Use one of the small instance types allowed in this lab."
  }
}

variable "instance_name" {
  description = "Optional Name tag for the instance. When null, a name is derived from project and environment."
  type        = string
  default     = null
}

variable "root_volume_size_gb" {
  description = "Size of the root EBS volume in GiB."
  type        = number
  default     = 8

  validation {
    condition     = var.root_volume_size_gb >= 8 && var.root_volume_size_gb <= 30
    error_message = "root_volume_size_gb must be between 8 and 30."
  }
}

variable "enable_detailed_monitoring" {
  description = "Enable 1-minute CloudWatch metrics for the instance (extra cost)."
  type        = bool
  default     = false
}

variable "extra_tags" {
  description = "Additional tags to merge onto every resource in this lab."
  type        = map(string)
  default     = {}
}
