data "aws_vpc" "default" {
  default = true
}

data "aws_ami" "al2023" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-2023.*-x86_64"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }
}

# --- Identity: let the SSM agent on the instance talk to AWS -------------

data "aws_iam_policy_document" "ec2_trust" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "instance" {
  name_prefix        = "tf-learning-ec2-ssm-"
  assume_role_policy = data.aws_iam_policy_document.ec2_trust.json
}

resource "aws_iam_role_policy_attachment" "ssm" {
  role       = aws_iam_role.instance.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_instance_profile" "instance" {
  name_prefix = "tf-learning-ec2-ssm-"
  role        = aws_iam_role.instance.name
}

# --- Network: no inbound rules at all ------------------------------------
# SSM Session Manager connections are started FROM the instance's agent
# (outbound HTTPS), so no SSH port and no key pair are needed.

resource "aws_security_group" "instance" {
  name_prefix = "tf-learning-ec2-ssm-"
  description = "No inbound access; outbound HTTPS for SSM and updates"
  vpc_id      = data.aws_vpc.default.id

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_vpc_security_group_egress_rule" "https" {
  security_group_id = aws_security_group.instance.id
  description       = "HTTPS to AWS APIs and package repositories"
  ip_protocol       = "tcp"
  from_port         = 443
  to_port           = 443
  cidr_ipv4         = "0.0.0.0/0"
}

# --- The instance --------------------------------------------------------

resource "aws_instance" "this" {
  ami                    = data.aws_ami.al2023.id
  instance_type          = var.instance_type
  iam_instance_profile   = aws_iam_instance_profile.instance.name
  vpc_security_group_ids = [aws_security_group.instance.id]

  # The default VPC has no NAT gateway, so the SSM agent needs a public
  # IP to reach the SSM endpoints. COST: public IPv4 addresses are billed
  # hourly. Private subnets + NAT or VPC endpoints avoid this (VPC track).
  associate_public_ip_address = true

  # user_data runs once, as root, on first boot (via cloud-init).
  user_data                   = file("${path.module}/user_data.sh")
  user_data_replace_on_change = true

  metadata_options {
    http_tokens = "required" # IMDSv2 only
  }

  root_block_device {
    volume_type = "gp3"
    volume_size = 8
    encrypted   = true
  }

  tags = {
    Name = "tf-learning-ssm-instance"
  }

  # The SSM agent registers at boot; make sure its permissions exist.
  depends_on = [aws_iam_role_policy_attachment.ssm]
}
