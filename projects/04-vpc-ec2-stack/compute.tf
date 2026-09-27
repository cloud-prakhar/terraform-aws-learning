data "aws_ami" "al2023" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-2023.*-x86_64"]
  }
}

# App server: private subnet, no public IP. Python ships with the AMI,
# so it can serve HTTP without downloading anything from the internet.
resource "aws_instance" "app" {
  #checkov:skip=CKV2_AWS_41:The app calls no AWS APIs, so least privilege means no role at all.
  ami                    = data.aws_ami.al2023.id
  instance_type          = var.instance_type
  subnet_id              = aws_subnet.private.id
  vpc_security_group_ids = [aws_security_group.app.id]

  user_data                   = <<-EOT
    #!/bin/bash
    mkdir -p /srv/app
    echo "<h1>Hello from the PRIVATE app server</h1>" > /srv/app/index.html
    # systemd-run starts the server as a managed service that survives
    # the end of the boot script.
    systemd-run --unit=app --working-directory=/srv/app python3 -m http.server 8080
  EOT
  user_data_replace_on_change = true

  metadata_options {
    http_tokens = "required"
  }

  root_block_device {
    encrypted = true
  }

  tags = {
    Name = "${var.name}-app"
  }
}

# Web server: public subnet, nginx reverse proxy to the app server.
# COST: two instances plus one public IPv4 address while running.
resource "aws_instance" "web" {
  #checkov:skip=CKV_AWS_88:The web proxy is the public entry point by design.
  ami                         = data.aws_ami.al2023.id
  instance_type               = var.instance_type
  subnet_id                   = aws_subnet.public.id
  vpc_security_group_ids      = [aws_security_group.web.id]
  iam_instance_profile        = aws_iam_instance_profile.web.name
  associate_public_ip_address = true

  # The app's private IP is only known after the app instance exists:
  # this reference makes Terraform create the app server first.
  user_data                   = <<-EOT
    #!/bin/bash
    dnf install -y nginx
    cat > /etc/nginx/conf.d/app.conf <<CONF
    server {
      listen 80 default_server;
      location / { proxy_pass http://${aws_instance.app.private_ip}:8080; }
    }
    CONF
    systemctl enable --now nginx
  EOT
  user_data_replace_on_change = true

  metadata_options {
    http_tokens = "required"
  }

  root_block_device {
    encrypted = true
  }

  tags = {
    Name = "${var.name}-web"
  }
}
