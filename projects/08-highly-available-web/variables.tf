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
  description = "Name prefix for all resources."
  type        = string
  default     = "tf-learning-p08"
}

variable "instance_type" {
  description = "Instance type for the web servers."
  type        = string
  default     = "t3.micro"
}

variable "min_size" {
  description = "Minimum number of instances. 2 = one per AZ, survives an AZ failure."
  type        = number
  default     = 2
}

variable "max_size" {
  description = "Maximum number of instances the group may scale out to."
  type        = number
  default     = 4
}

variable "target_cpu_percent" {
  description = "Auto Scaling adds/removes instances to keep average CPU near this value."
  type        = number
  default     = 50
}
