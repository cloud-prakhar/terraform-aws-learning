provider "aws" {
  region = var.aws_region

  # null = use the standard AWS credential chain (environment variables,
  # AWS_PROFILE, SSO session, instance role, ...). Never put keys here.
  profile = var.aws_profile

  # Tags added to every resource this provider creates.
  default_tags {
    tags = {
      Project   = "terraform-aws-learning"
      Lab       = "remote-state-bootstrap"
      ManagedBy = "Terraform"
    }
  }
}
