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

variable "instance_class" {
  description = "DB instance size. Burstable classes are the cheapest."
  type        = string
  default     = "db.t4g.micro"
}

variable "engine_version" {
  description = "PostgreSQL major version. RDS picks the default minor version."
  type        = string
  default     = "17"
}

variable "deletion_protection" {
  description = "Block deletion of the database. Set true for anything that holds real data."
  type        = bool
  default     = false
}
