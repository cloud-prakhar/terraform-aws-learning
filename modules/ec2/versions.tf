terraform {
  required_version = ">= 1.11.0"

  required_providers {
    aws = {
      source = "hashicorp/aws"
      # Modules declare the MINIMUM they need, not an upper bound, so the
      # root module stays free to choose the exact provider version.
      version = ">= 6.0"
    }
  }
}
