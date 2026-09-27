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

variable "servers" {
  description = "Servers to create: name => settings. Each gets its own data volume."
  type = map(object({
    az_index       = number # which AZ (0, 1, ...) to place the server in
    instance_type  = optional(string, "t3.micro")
    data_volume_gb = optional(number, 10)
  }))
  default = {
    app-a = { az_index = 0 }
    app-b = { az_index = 1, data_volume_gb = 20 }
  }
}
