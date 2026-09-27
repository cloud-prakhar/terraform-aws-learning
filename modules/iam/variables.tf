variable "name" {
  description = "Name of the IAM role."
  type        = string
}

variable "description" {
  description = "Human-readable description of what the role is for."
  type        = string
  default     = "Managed by Terraform"
}

variable "trusted_services" {
  description = "AWS service principals allowed to assume the role, e.g. [\"ec2.amazonaws.com\"]. This becomes the TRUST policy."
  type        = list(string)

  validation {
    condition     = length(var.trusted_services) > 0 && alltrue([for s in var.trusted_services : endswith(s, ".amazonaws.com")])
    error_message = "trusted_services must contain at least one AWS service principal ending in .amazonaws.com."
  }
}

variable "managed_policy_arns" {
  description = "ARNs of managed policies to attach (PERMISSIONS)."
  type        = list(string)
  default     = []
}

variable "inline_policies" {
  description = "Inline permissions policies: map of policy name => policy JSON (e.g. from aws_iam_policy_document). Keys must be known at plan time; values may be computed."
  type        = map(string)
  default     = {}
}

variable "create_instance_profile" {
  description = "Also create an instance profile so EC2 instances can use the role."
  type        = bool
  default     = false
}

variable "tags" {
  description = "Tags to add to the role and instance profile."
  type        = map(string)
  default     = {}
}
