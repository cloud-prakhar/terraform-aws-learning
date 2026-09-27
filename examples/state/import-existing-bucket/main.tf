# Import only fills in STATE. You still have to write configuration that
# matches the real bucket, otherwise the next plan proposes changes.
# `terraform plan -generate-config-out=generated.tf` can draft it for you
# (see README), but always review generated code.
resource "aws_s3_bucket" "legacy" {
  bucket = var.existing_bucket_name
}
