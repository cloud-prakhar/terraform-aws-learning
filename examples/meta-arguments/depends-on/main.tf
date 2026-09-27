data "aws_ami" "al2023" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-2023.*-x86_64"]
  }
}

data "aws_iam_policy_document" "ec2_trust" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_s3_bucket" "config" {
  bucket_prefix = "tf-learning-config-"
  force_destroy = true
}

resource "aws_iam_role" "app" {
  name_prefix        = "tf-learning-app-"
  assume_role_policy = data.aws_iam_policy_document.ec2_trust.json
}

data "aws_iam_policy_document" "read_config" {
  statement {
    actions   = ["s3:GetObject", "s3:ListBucket"]
    resources = [aws_s3_bucket.config.arn, "${aws_s3_bucket.config.arn}/*"]
  }
}

resource "aws_iam_role_policy" "read_config" {
  name   = "read-config-bucket"
  role   = aws_iam_role.app.id
  policy = data.aws_iam_policy_document.read_config.json
}

resource "aws_iam_instance_profile" "app" {
  name_prefix = "tf-learning-app-"
  role        = aws_iam_role.app.name
}

resource "aws_instance" "app" {
  ami           = data.aws_ami.al2023.id
  instance_type = "t3.micro"

  # The default VPC has no NAT gateway, so the instance needs a public IP
  # to reach the S3 API. COST: public IPv4 addresses are billed hourly.
  associate_public_ip_address = true

  # Implicit dependency: Terraform sees this reference and creates the
  # instance profile (and therefore the role) first.
  iam_instance_profile = aws_iam_instance_profile.app.name

  # This boot script reads from S3 the moment the instance starts, so it
  # needs the role's POLICY to exist too. Nothing in this block
  # references aws_iam_role_policy.read_config, so Terraform cannot know
  # about that requirement. depends_on declares the hidden dependency.
  # tee also sends the result to the serial console, which you can read
  # with `aws ec2 get-console-output` (see README).
  user_data = <<-EOT
    #!/bin/bash
    aws s3 ls "s3://${aws_s3_bucket.config.bucket}/" 2>&1 | tee /var/log/config-check.log
    echo "config-check exit code: $${PIPESTATUS[0]}"
  EOT

  depends_on = [aws_iam_role_policy.read_config]

  metadata_options {
    http_tokens = "required"
  }

  root_block_device {
    encrypted = true
  }

  tags = {
    Name = "depends-on-demo"
  }
}
