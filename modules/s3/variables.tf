variable "bucket_prefix" {
  description = "Prefix for the bucket name. AWS appends a unique suffix so names never collide."
  type        = string

  validation {
    condition     = can(regex("^[a-z0-9][a-z0-9-]{1,35}$", var.bucket_prefix))
    error_message = "bucket_prefix must be 2-36 lowercase letters, numbers or hyphens, starting with a letter or number."
  }
}

variable "force_destroy" {
  description = "Allow Terraform to delete the bucket even when it contains objects. Keep false for real data."
  type        = bool
  default     = false
}

variable "versioning_enabled" {
  description = "Keep previous versions of every object so deletes and overwrites can be undone."
  type        = bool
  default     = true
}

variable "kms_key_arn" {
  description = "ARN of a customer managed KMS key for SSE-KMS. When null, SSE-S3 (AES256) is used."
  type        = string
  default     = null
}

variable "noncurrent_version_expiration_days" {
  description = "Delete previous object versions after this many days. Only applies when versioning is enabled."
  type        = number
  default     = 90

  validation {
    condition     = var.noncurrent_version_expiration_days >= 1
    error_message = "noncurrent_version_expiration_days must be at least 1."
  }
}

variable "tags" {
  description = "Tags to add to the bucket."
  type        = map(string)
  default     = {}
}
