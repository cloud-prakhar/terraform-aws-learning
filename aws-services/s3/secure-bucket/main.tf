# In AWS provider v4+ a bucket is configured with SEPARATE resources
# (versioning, encryption, lifecycle, policy, ...). Each resource below
# owns exactly one aspect of the bucket.

resource "aws_s3_bucket" "this" {
  bucket_prefix = var.bucket_prefix
  force_destroy = true # lab only: allows destroy with objects inside
}

# Object ownership: disable ACLs so only policies control access.
resource "aws_s3_bucket_ownership_controls" "this" {
  bucket = aws_s3_bucket.this.id

  rule {
    object_ownership = "BucketOwnerEnforced"
  }
}

# Public access block: a safety net that overrides any public policy/ACL.
# New buckets have this enabled by default; managing it in Terraform
# makes the intent explicit and prevents drift.
resource "aws_s3_bucket_public_access_block" "this" {
  bucket = aws_s3_bucket.this.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# Versioning: overwrites and deletes keep the previous version.
resource "aws_s3_bucket_versioning" "this" {
  bucket = aws_s3_bucket.this.id

  versioning_configuration {
    status = "Enabled"
  }
}

# Encryption at rest. S3 encrypts new objects with SSE-S3 by default;
# declaring it documents the choice. aws-services/kms shows SSE-KMS.
resource "aws_s3_bucket_server_side_encryption_configuration" "this" {
  bucket = aws_s3_bucket.this.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# Lifecycle rules move or delete objects automatically, which is how
# you keep storage costs under control.
resource "aws_s3_bucket_lifecycle_configuration" "this" {
  bucket = aws_s3_bucket.this.id

  rule {
    id     = "logs"
    status = "Enabled"

    filter {
      prefix = "logs/"
    }

    # Infrequently read logs are cheaper to store in STANDARD_IA.
    transition {
      days          = 30
      storage_class = "STANDARD_IA"
    }

    expiration {
      days = var.log_retention_days
    }
  }

  rule {
    id     = "cleanup-old-versions"
    status = "Enabled"

    filter {}

    noncurrent_version_expiration {
      noncurrent_days = 30
    }

    abort_incomplete_multipart_upload {
      days_after_initiation = 7
    }
  }

  depends_on = [aws_s3_bucket_versioning.this]
}

# Bucket policy: deny any request that is not sent over HTTPS.
data "aws_iam_policy_document" "bucket" {
  statement {
    sid       = "DenyInsecureTransport"
    effect    = "Deny"
    actions   = ["s3:*"]
    resources = [aws_s3_bucket.this.arn, "${aws_s3_bucket.this.arn}/*"]

    principals {
      type        = "*"
      identifiers = ["*"]
    }

    condition {
      test     = "Bool"
      variable = "aws:SecureTransport"
      values   = ["false"]
    }
  }
}

resource "aws_s3_bucket_policy" "this" {
  bucket = aws_s3_bucket.this.id
  policy = data.aws_iam_policy_document.bucket.json

  depends_on = [aws_s3_bucket_public_access_block.this]
}

# A small object so there is something to look at. Terraform can manage
# objects, but it is not a file-sync tool: use it for config files, not
# for application data.
resource "aws_s3_object" "readme" {
  bucket       = aws_s3_bucket.this.id
  key          = "docs/readme.txt"
  content      = "This bucket was created by Terraform."
  content_type = "text/plain"
}
