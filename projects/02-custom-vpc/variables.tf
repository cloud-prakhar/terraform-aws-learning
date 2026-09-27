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
  description = "Name prefix for all networking resources."
  type        = string
  default     = "tf-learning-p02"
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC."
  type        = string
  default     = "10.10.0.0/16"
}

variable "az_count" {
  description = "Number of Availability Zones (2 or 3)."
  type        = number
  default     = 2

  validation {
    condition     = contains([2, 3], var.az_count)
    error_message = "az_count must be 2 or 3."
  }
}

variable "nat_gateway_mode" {
  description = "none = no outbound internet for private tiers (free); single = one shared NAT gateway; per_az = one NAT gateway per AZ (highest availability, highest cost)."
  type        = string
  default     = "none"

  validation {
    condition     = contains(["none", "single", "per_az"], var.nat_gateway_mode)
    error_message = "nat_gateway_mode must be none, single or per_az."
  }
}
