terraform {
  # 1.11+ is needed for S3 native state locking and write-only arguments,
  # which later chapters use. Newer 1.x releases work too.
  required_version = ">= 1.11.0"

  required_providers {
    aws = {
      source = "hashicorp/aws"
      # "~> 6.0" = any 6.x release, but never 7.0 (which may contain breaking changes).
      version = "~> 6.0"
    }
    # Builds the .zip deployment package from source on your machine.
    archive = {
      source  = "hashicorp/archive"
      version = "~> 2.7"
    }
  }
}
