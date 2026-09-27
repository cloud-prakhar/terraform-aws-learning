data "aws_ami" "al2023" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-2023.*-x86_64"]
  }
}

data "aws_vpc" "default" {
  default = true
}

# ---------------------------------------------------------------------
# create_before_destroy
# Changing `description` forces a new security group. By default
# Terraform destroys first, which fails while an instance still uses the
# group. Creating the replacement first avoids that. It only works
# because name_prefix gives the new group a different name.
# ---------------------------------------------------------------------
resource "aws_security_group" "app" {
  name_prefix = "tf-learning-lifecycle-"
  description = "App security group (edit me to force a replacement)"
  vpc_id      = data.aws_vpc.default.id

  lifecycle {
    create_before_destroy = true
  }
}

# terraform_data is a built-in resource that just stores a value.
# Here it acts as a "version marker" that other resources can watch.
resource "terraform_data" "app_version" {
  input = var.app_version
}

resource "aws_instance" "app" {
  ami                         = data.aws_ami.al2023.id
  instance_type               = "t3.micro"
  associate_public_ip_address = false
  vpc_security_group_ids      = [aws_security_group.app.id]

  metadata_options {
    http_tokens = "required"
  }

  root_block_device {
    encrypted = true
  }

  tags = {
    Name       = "lifecycle-demo"
    AppVersion = var.app_version
  }

  lifecycle {
    # A new AMI is published every few weeks. Without this, every new AMI
    # would make `plan` want to replace the instance. We choose to roll
    # AMIs deliberately instead.
    ignore_changes = [ami]

    # Replace the instance whenever the app version marker changes.
    replace_triggered_by = [terraform_data.app_version]

    # Fail the plan early, with a clear message, if the AMI lookup ever
    # returns something unexpected.
    precondition {
      condition     = data.aws_ami.al2023.architecture == "x86_64"
      error_message = "The selected AMI must be x86_64 to run on t3 instances."
    }
  }
}

# ---------------------------------------------------------------------
# prevent_destroy
# lifecycle arguments must be literal values (no variables), because
# Terraform evaluates them before anything else. The README exercise
# asks you to flip this to true and then run `terraform destroy`.
# ---------------------------------------------------------------------
resource "aws_s3_bucket" "important" {
  bucket_prefix = "tf-learning-important-"
  force_destroy = true

  lifecycle {
    prevent_destroy = false
  }
}
