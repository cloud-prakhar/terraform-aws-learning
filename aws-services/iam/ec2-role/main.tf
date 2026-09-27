# The data this role is allowed to read.
resource "aws_s3_bucket" "app_config" {
  bucket_prefix = "tf-learning-iam-lab-"
  force_destroy = true
}

# ---------------------------------------------------------------------
# 1. TRUST POLICY – who can assume (become) the role?
#    Answer: the EC2 service, on behalf of instances.
# ---------------------------------------------------------------------
data "aws_iam_policy_document" "ec2_trust" {
  statement {
    sid     = "AllowEC2ToAssumeRole"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "app" {
  name               = "tf-learning-app-role"
  description        = "Lets application instances read their config bucket"
  assume_role_policy = data.aws_iam_policy_document.ec2_trust.json
}

# ---------------------------------------------------------------------
# 2. PERMISSIONS POLICY – what can the role do?
#    Least privilege: read-only, one bucket, one prefix.
# ---------------------------------------------------------------------
data "aws_iam_policy_document" "read_config" {
  statement {
    sid       = "ListConfigPrefix"
    actions   = ["s3:ListBucket"]
    resources = [aws_s3_bucket.app_config.arn]

    condition {
      test     = "StringLike"
      variable = "s3:prefix"
      values   = ["config/*"]
    }
  }

  statement {
    sid       = "ReadConfigObjects"
    actions   = ["s3:GetObject"]
    resources = ["${aws_s3_bucket.app_config.arn}/config/*"]
  }
}

# A customer managed policy is a standalone, reusable object with its
# own ARN. (An inline aws_iam_role_policy would live inside the role.)
resource "aws_iam_policy" "read_config" {
  name        = "tf-learning-read-app-config"
  description = "Read objects under config/ in the app config bucket"
  policy      = data.aws_iam_policy_document.read_config.json
}

resource "aws_iam_role_policy_attachment" "read_config" {
  role       = aws_iam_role.app.name
  policy_arn = aws_iam_policy.read_config.arn
}

# AWS managed policy: lets SSM Session Manager manage the instance, so
# you can open a shell without SSH keys or open inbound ports.
resource "aws_iam_role_policy_attachment" "ssm" {
  role       = aws_iam_role.app.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

# ---------------------------------------------------------------------
# 3. INSTANCE PROFILE – the container EC2 uses to carry the role.
# ---------------------------------------------------------------------
resource "aws_iam_instance_profile" "app" {
  name = "tf-learning-app-profile"
  role = aws_iam_role.app.name
}
