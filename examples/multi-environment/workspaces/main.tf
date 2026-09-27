# terraform.workspace is the name of the currently selected workspace
# ("default", "dev", "prod", ...). Each workspace has its own state, so
# the same code creates a separate copy of everything per workspace.

locals {
  environment = terraform.workspace

  # Per-workspace settings. lookup() falls back to the "default" entry
  # for any workspace not listed.
  settings = {
    default = { message_retention_seconds = 3600, versioning = false }
    dev     = { message_retention_seconds = 3600, versioning = false }
    prod    = { message_retention_seconds = 1209600, versioning = true }
  }
  config = lookup(local.settings, local.environment, local.settings["default"])
}

resource "aws_sqs_queue" "events" {
  # The workspace name makes names unique per environment.
  name                      = "tf-learning-${local.environment}-events"
  message_retention_seconds = local.config.message_retention_seconds
  sqs_managed_sse_enabled   = true

  tags = {
    Environment = local.environment
  }
}

resource "aws_s3_bucket" "data" {
  bucket_prefix = "tf-learning-${local.environment}-data-"
  force_destroy = true

  tags = {
    Environment = local.environment
  }
}

resource "aws_s3_bucket_versioning" "data" {
  bucket = aws_s3_bucket.data.id

  versioning_configuration {
    status = local.config.versioning ? "Enabled" : "Suspended"
  }
}
