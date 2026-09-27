variable "name" {
  description = "Name prefix for every networking resource."
  type        = string
}

variable "cidr_block" {
  description = "IPv4 CIDR block for the VPC. /16 gives 65,536 addresses to split into subnets."
  type        = string
  default     = "10.0.0.0/16"

  validation {
    condition     = can(cidrhost(var.cidr_block, 0))
    error_message = "cidr_block must be a valid IPv4 CIDR, e.g. 10.0.0.0/16."
  }
}

variable "az_count" {
  description = "Number of Availability Zones to spread subnets across."
  type        = number
  default     = 2

  validation {
    condition     = var.az_count >= 1 && var.az_count <= 3
    error_message = "az_count must be between 1 and 3."
  }
}

variable "create_private_subnets" {
  description = "Create one private subnet per AZ (no direct route to the internet)."
  type        = bool
  default     = true
}

variable "enable_nat_gateway" {
  description = "Create ONE NAT gateway so private subnets can reach the internet. Costs money every hour it exists."
  type        = bool
  default     = false
}

variable "tags" {
  description = "Tags to add to every resource."
  type        = map(string)
  default     = {}
}
