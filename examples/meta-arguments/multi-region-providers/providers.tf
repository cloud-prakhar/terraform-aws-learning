provider "aws" {
  region = var.aws_region

  # null = use the standard AWS credential chain (environment variables,
  # AWS_PROFILE, SSO session, instance role, ...). Never put keys here.
  profile = var.aws_profile

  # Tags added to every resource this provider creates.
  default_tags {
    tags = {
      Project   = "terraform-aws-learning"
      Lab       = "meta-multi-region"
      ManagedBy = "Terraform"
    }
  }
}

# A second configuration of the same provider. The alias gives it a name
# so resources can opt into it with `provider = aws.secondary`.
provider "aws" {
  alias   = "secondary"
  region  = var.secondary_region
  profile = var.aws_profile

  default_tags {
    tags = {
      Project   = "terraform-aws-learning"
      Lab       = "meta-multi-region"
      ManagedBy = "Terraform"
    }
  }
}
