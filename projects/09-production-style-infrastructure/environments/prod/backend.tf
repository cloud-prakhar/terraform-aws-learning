# Remote state in the bucket created by ../../bootstrap.
# bucket and region are supplied at init time:
#   locally: terraform init -backend-config=../../backend.hcl
#   CI:      terraform init -backend-config="bucket=$TF_STATE_BUCKET" ...
terraform {
  backend "s3" {
    key          = "projects/09/prod/terraform.tfstate"
    encrypt      = true
    use_lockfile = true
  }
}
