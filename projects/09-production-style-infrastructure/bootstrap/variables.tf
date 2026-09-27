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

variable "github_repository" {
  description = "GitHub repository allowed to deploy, as OWNER/NAME. Change this to your fork."
  type        = string
  default     = "cloud-prakhar/terraform-aws-learning"

  validation {
    condition     = can(regex("^[A-Za-z0-9_.-]+/[A-Za-z0-9_.-]+$", var.github_repository))
    error_message = "github_repository must look like OWNER/NAME."
  }
}

variable "environments" {
  description = "GitHub Environments that get their own deploy role (must match the environment names in the workflows)."
  type        = set(string)
  default     = ["dev", "prod"]
}

variable "app_name" {
  description = "Application name used by environments/*; deploy roles are limited to resources with this prefix."
  type        = string
  default     = "shop"
}

variable "create_oidc_provider" {
  description = "An AWS account can have only ONE GitHub OIDC provider. Set false if it already exists."
  type        = bool
  default     = true
}
