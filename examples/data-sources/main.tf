# A bucket whose name is built from data-source values. Account ID +
# Region makes the name predictable for you and unique across AWS.
resource "aws_s3_bucket" "reports" {
  bucket        = "${local.name_prefix}-reports-${local.account_id}-${local.region}"
  force_destroy = true

  tags = merge(local.common_tags, { Purpose = "data-source-demo" })
}
