# COST: every customer managed KMS key has a monthly charge (prorated
# while it exists) plus a per-request charge. Scheduling deletion stops
# the monthly charge once the key is actually deleted.

data "aws_caller_identity" "current" {}

# A KEY POLICY is the primary access control for a KMS key. Unlike most
# AWS resources, IAM policies alone cannot grant access to a key unless
# the key policy allows it.
#
# This statement is AWS's default: it lets the account (i.e. IAM
# policies in this account) control access to the key. Without it you
# could lock everyone, including yourself, out of the key.
data "aws_iam_policy_document" "key" {
  statement {
    sid       = "EnableIAMPolicies"
    actions   = ["kms:*"]
    resources = ["*"] # in a key policy, "*" means "this key"

    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"]
    }
  }
}

resource "aws_kms_key" "data" {
  description = "tf-learning: encrypts objects in the lab bucket"
  policy      = data.aws_iam_policy_document.key.json

  # Automatic yearly rotation of the key material. Old material is kept,
  # so data encrypted earlier can still be decrypted.
  enable_key_rotation = true

  # Waiting period (7-30 days) before a deleted key is really deleted.
  # Deleting a key makes everything encrypted with it unreadable, so AWS
  # forces a waiting period during which you can cancel the deletion.
  deletion_window_in_days = 7
}

# An alias is a friendly, stable name that can be re-pointed to a new
# key later. Aliases must start with "alias/".
resource "aws_kms_alias" "data" {
  name          = "alias/tf-learning-data"
  target_key_id = aws_kms_key.data.key_id
}

# --- Using the key: S3 server-side encryption with KMS (SSE-KMS) --------

resource "aws_s3_bucket" "encrypted" {
  bucket_prefix = "tf-learning-kms-"
  force_destroy = true
}

resource "aws_s3_bucket_server_side_encryption_configuration" "encrypted" {
  bucket = aws_s3_bucket.encrypted.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm     = "aws:kms"
      kms_master_key_id = aws_kms_key.data.arn
    }

    # S3 Bucket Keys: S3 asks KMS for a bucket-level key and reuses it,
    # which drastically reduces KMS request charges.
    bucket_key_enabled = true
  }
}

resource "aws_s3_bucket_public_access_block" "encrypted" {
  bucket = aws_s3_bucket.encrypted.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}
