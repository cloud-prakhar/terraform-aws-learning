variable "name" {
  description = "Name prefix for the instances and security group."
  type        = string
}

variable "vpc_id" {
  description = "VPC in which to create the security group."
  type        = string
}

variable "subnet_ids" {
  description = "Subnets to place instances in. Instances are spread round-robin across them."
  type        = list(string)

  validation {
    condition     = length(var.subnet_ids) > 0
    error_message = "Provide at least one subnet ID."
  }
}

variable "instance_count" {
  description = "Number of instances to create."
  type        = number
  default     = 1

  validation {
    condition     = var.instance_count >= 0 && var.instance_count <= 10
    error_message = "instance_count must be between 0 and 10."
  }
}

variable "instance_type" {
  description = "EC2 instance type."
  type        = string
  default     = "t3.micro"
}

variable "ami_id" {
  description = "AMI to launch. When null, the latest Amazon Linux 2023 x86_64 AMI is used."
  type        = string
  default     = null
}

variable "associate_public_ip" {
  description = "Give instances a public IPv4 address (billed hourly). Only works in public subnets."
  type        = bool
  default     = false
}

variable "iam_instance_profile" {
  description = "Name of an IAM instance profile to attach, or null."
  type        = string
  default     = null
}

variable "user_data" {
  description = "Boot script (cloud-init). Changing it replaces the instances."
  type        = string
  default     = null
}

variable "root_volume_size_gb" {
  description = "Root EBS volume size in GiB."
  type        = number
  default     = 8
}

variable "ingress_rules" {
  description = "Inbound rules for the instance security group. Use either cidr_ipv4 or source_security_group_id per rule."
  type = map(object({
    description              = string
    port                     = number
    protocol                 = optional(string, "tcp")
    cidr_ipv4                = optional(string)
    source_security_group_id = optional(string)
  }))
  default = {}

  validation {
    condition = alltrue([
      for rule in values(var.ingress_rules) : (rule.cidr_ipv4 == null) != (rule.source_security_group_id == null)
    ])
    error_message = "Each ingress rule needs exactly one of cidr_ipv4 or source_security_group_id."
  }
}

variable "tags" {
  description = "Tags to add to every resource."
  type        = map(string)
  default     = {}
}
