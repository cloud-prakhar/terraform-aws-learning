# The bucket that stores the state of environments/dev and environments/prod.
# Reuses the s3 module: versioned, encrypted, private, TLS-only.
#
# This bootstrap configuration itself uses LOCAL state (chicken-and-egg).
# Keep its terraform.tfstate somewhere safe, or migrate it into the new
# bucket afterwards (see README).
module "state_bucket" {
  source = "../../../modules/s3"

  bucket_prefix                      = "tf-learning-p09-state-"
  versioning_enabled                 = true
  force_destroy                      = false
  noncurrent_version_expiration_days = 90

  tags = {
    Purpose = "terraform-state"
  }
}
