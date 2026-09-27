# The S3 backend stores terraform.tfstate in S3 instead of on your disk.
#
# Backend blocks cannot use variables, because Terraform needs the
# backend before it evaluates anything else. So values that differ per
# person/environment are passed at init time ("partial configuration"):
#
#   cp backend.hcl.example backend.hcl   # edit bucket name
#   terraform init -backend-config=backend.hcl
terraform {
  backend "s3" {
    # Path of the state object inside the bucket. One key per
    # configuration/environment keeps states isolated.
    key = "examples/remote-state-backend/terraform.tfstate"

    # bucket, region, encrypt and use_lockfile come from backend.hcl.
  }
}
