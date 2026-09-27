# COST: one customer managed KMS key (monthly charge + requests).

data "aws_caller_identity" "current" {}

locals {
  account_root = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
}

data "aws_iam_policy_document" "key" {
  #checkov:skip=CKV_AWS_109:AWS default key policy statement; in a key policy "*" refers only to this key.
  #checkov:skip=CKV_AWS_111:AWS default key policy statement; in a key policy "*" refers only to this key.
  #checkov:skip=CKV_AWS_356:AWS default key policy statement; in a key policy "*" refers only to this key.
  # Keep the account in control of the key (prevents lock-out).
  statement {
    sid       = "EnableIAMPolicies"
    actions   = ["kms:*"]
    resources = ["*"]

    principals {
      type        = "AWS"
      identifiers = [local.account_root]
    }
  }

  # The writer role may encrypt (GenerateDataKey) and the reader role
  # may decrypt. These grants live in the KEY policy, so even an IAM
  # admin cannot use the key through S3 without the matching IAM grants.
  statement {
    sid       = "WriterEncrypt"
    actions   = ["kms:GenerateDataKey", "kms:Decrypt"]
    resources = ["*"]

    principals {
      type        = "AWS"
      identifiers = [aws_iam_role.writer.arn]
    }
  }

  statement {
    sid       = "ReaderDecrypt"
    actions   = ["kms:Decrypt"]
    resources = ["*"]

    principals {
      type        = "AWS"
      identifiers = [aws_iam_role.reader.arn]
    }
  }
}

resource "aws_kms_key" "data" {
  description             = "${var.name}: encrypts the secure data bucket"
  policy                  = data.aws_iam_policy_document.key.json
  enable_key_rotation     = true
  deletion_window_in_days = 7
}

resource "aws_kms_alias" "data" {
  name          = "alias/${var.name}-data"
  target_key_id = aws_kms_key.data.key_id
}
