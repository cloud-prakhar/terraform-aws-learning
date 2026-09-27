# An import block tells Terraform: "the resource at this address already
# exists in AWS; record it in state instead of creating it".
# It is processed during plan/apply, so you can review it first.
import {
  to = aws_s3_bucket.legacy
  id = var.existing_bucket_name
}
