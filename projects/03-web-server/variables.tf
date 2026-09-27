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
  description = "Name of the web server."
  type        = string
  default     = "tf-learning-web"
}

variable "instance_type" {
  description = "EC2 instance type."
  type        = string
  default     = "t3.micro"
}

variable "allowed_http_cidrs" {
  description = "Who may open the website. Default: everyone. Use [\"<your-ip>/32\"] to restrict it to you."
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "page_title" {
  description = "Text rendered into the home page by templatefile()."
  type        = string
  default     = "Built with Terraform"
}
