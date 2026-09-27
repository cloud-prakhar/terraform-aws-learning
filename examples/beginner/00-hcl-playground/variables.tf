variable "environment" {
  description = "Deployment environment. Try: terraform console -var environment=prod"
  type        = string
  default     = "dev"

  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "environment must be one of: dev, staging, prod."
  }
}

variable "availability_zones" {
  description = "A list: ordered, duplicates allowed, accessed by index."
  type        = list(string)
  default     = ["us-east-1a", "us-east-1b", "us-east-1c"]
}

variable "instance_types" {
  description = "A map: string keys to values of one type."
  type        = map(string)
  default = {
    dev     = "t3.micro"
    staging = "t3.small"
    prod    = "t3.medium"
  }
}

variable "servers" {
  description = "A list of objects: each object has named attributes with their own types."
  type = list(object({
    name    = string
    size_gb = number
    public  = bool
  }))
  default = [
    { name = "web", size_gb = 20, public = true },
    { name = "api", size_gb = 30, public = false },
    { name = "worker", size_gb = 50, public = false },
  ]
}
