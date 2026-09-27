# Two roles that people in THIS account can assume to test access:
#   writer – upload objects      reader – download objects
# Trusting the account root means "any IAM principal in this account
# that is ALSO allowed sts:AssumeRole on this role by its own policy".

data "aws_iam_policy_document" "assume_from_account" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "AWS"
      identifiers = [local.account_root]
    }
  }
}

resource "aws_iam_role" "writer" {
  name               = "${var.name}-writer"
  assume_role_policy = data.aws_iam_policy_document.assume_from_account.json
}

resource "aws_iam_role" "reader" {
  name               = "${var.name}-reader"
  assume_role_policy = data.aws_iam_policy_document.assume_from_account.json
}

data "aws_iam_policy_document" "writer" {
  statement {
    actions   = ["s3:PutObject"]
    resources = ["${aws_s3_bucket.data.arn}/*"]
  }

  statement {
    actions   = ["kms:GenerateDataKey", "kms:Decrypt"]
    resources = [aws_kms_key.data.arn]
  }
}

data "aws_iam_policy_document" "reader" {
  statement {
    actions   = ["s3:ListBucket"]
    resources = [aws_s3_bucket.data.arn]
  }

  statement {
    actions   = ["s3:GetObject"]
    resources = ["${aws_s3_bucket.data.arn}/*"]
  }

  statement {
    actions   = ["kms:Decrypt"]
    resources = [aws_kms_key.data.arn]
  }
}

resource "aws_iam_role_policy" "writer" {
  name   = "write-secure-data"
  role   = aws_iam_role.writer.id
  policy = data.aws_iam_policy_document.writer.json
}

resource "aws_iam_role_policy" "reader" {
  name   = "read-secure-data"
  role   = aws_iam_role.reader.id
  policy = data.aws_iam_policy_document.reader.json
}
