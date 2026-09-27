provider "aws" {
  region = "us-east-1"
}

# AMI IDs are different in every Region and change whenever Amazon
# publishes a patched image, so we look up the latest one instead of
# hard-coding an ID. Data sources are covered properly in Chapter 08.
data "aws_ami" "al2023" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-2023.*-x86_64"]
  }
}

resource "aws_instance" "first" {
  ami           = data.aws_ami.al2023.id
  instance_type = "t3.micro"

  # No public IP: this lab does not need internet access, and AWS bills
  # every public IPv4 address by the hour.
  associate_public_ip_address = false

  # Require IMDSv2 session tokens for the instance metadata service.
  # This blocks a common credential-theft technique (SSRF → IMDSv1).
  metadata_options {
    http_tokens = "required"
  }

  root_block_device {
    encrypted = true
  }

  tags = {
    Name      = "my-first-terraform-instance"
    ManagedBy = "Terraform"
  }
}

output "instance_id" {
  description = "ID of the EC2 instance."
  value       = aws_instance.first.id
}

output "private_ip" {
  description = "Private IP address assigned inside the default VPC."
  value       = aws_instance.first.private_ip
}
