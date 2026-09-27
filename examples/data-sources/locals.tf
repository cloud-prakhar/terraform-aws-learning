locals {
  account_id = data.aws_caller_identity.current.account_id
  region     = data.aws_region.current.region

  # Computed once, reused everywhere.
  name_prefix = "${var.project_name}-${var.environment}"

  # Take only the first two AZs; many labs need exactly two.
  azs = slice(data.aws_availability_zones.available.names, 0, 2)

  common_tags = {
    Environment = var.environment
    Project     = var.project_name
    ManagedBy   = "Terraform"
  }
}
