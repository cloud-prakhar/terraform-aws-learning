locals {
  # Use the caller's name if provided, otherwise build one.
  instance_name = coalesce(var.instance_name, "${var.project_name}-${var.environment}-web")

  tags = merge(
    {
      Environment = var.environment
    },
    var.extra_tags,
  )
}

data "aws_ami" "al2023" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-2023.*-x86_64"]
  }
}

resource "aws_instance" "web" {
  ami                         = data.aws_ami.al2023.id
  instance_type               = var.instance_type
  monitoring                  = var.enable_detailed_monitoring
  associate_public_ip_address = false

  metadata_options {
    http_tokens = "required"
  }

  root_block_device {
    volume_size = var.root_volume_size_gb
    volume_type = "gp3"
    encrypted   = true
  }

  tags = merge(local.tags, { Name = local.instance_name })
}

resource "aws_s3_bucket" "artifacts" {
  bucket_prefix = "${var.project_name}-${var.environment}-artifacts-"

  # Allows `terraform destroy` to delete the bucket even if you uploaded
  # objects during the lab. Keep this false for real data.
  force_destroy = true

  tags = local.tags
}
