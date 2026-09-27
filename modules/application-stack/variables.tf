variable "name" {
  description = "Application name, used as a prefix for every resource."
  type        = string

  validation {
    condition     = can(regex("^[a-z][a-z0-9-]{2,20}$", var.name))
    error_message = "name must be 3-21 lowercase letters, numbers or hyphens, starting with a letter."
  }
}

variable "environment" {
  description = "Environment name, e.g. dev or prod."
  type        = string
}

variable "vpc_cidr" {
  description = "CIDR block for the application VPC."
  type        = string
  default     = "10.0.0.0/16"
}

variable "az_count" {
  description = "Number of Availability Zones."
  type        = number
  default     = 2
}

variable "enable_nat_gateway" {
  description = "Create a NAT gateway (hourly cost). Required for instances in private subnets to reach the internet."
  type        = bool
  default     = false
}

variable "instance_subnet_tier" {
  description = "Where to run instances: \"public\" (public IP, no NAT needed) or \"private\" (needs NAT)."
  type        = string
  default     = "public"

  validation {
    condition     = contains(["public", "private"], var.instance_subnet_tier)
    error_message = "instance_subnet_tier must be \"public\" or \"private\"."
  }
}

variable "instance_count" {
  description = "Number of application instances."
  type        = number
  default     = 1
}

variable "instance_type" {
  description = "EC2 instance type for the application."
  type        = string
  default     = "t3.micro"
}

variable "allowed_http_cidrs" {
  description = "IPv4 CIDRs allowed to reach the instances on port 80. Empty = no inbound HTTP."
  type        = list(string)
  default     = []
}

variable "tags" {
  description = "Extra tags added to every resource."
  type        = map(string)
  default     = {}
}
