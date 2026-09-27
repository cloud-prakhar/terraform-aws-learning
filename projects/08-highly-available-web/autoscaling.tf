data "aws_ami" "al2023" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-2023.*-x86_64"]
  }
}

# A launch template is the "recipe" Auto Scaling uses for every instance.
resource "aws_launch_template" "web" {
  name_prefix   = "${var.name}-"
  image_id      = data.aws_ami.al2023.id
  instance_type = var.instance_type

  vpc_security_group_ids = [aws_security_group.web.id]

  # Each instance serves a page naming itself, so refreshing the
  # load balancer URL shows requests landing on different instances.
  user_data = base64encode(<<-EOT
    #!/bin/bash
    TOKEN=$(curl -s -X PUT http://169.254.169.254/latest/api/token -H "X-aws-ec2-metadata-token-ttl-seconds: 60")
    ID=$(curl -s -H "X-aws-ec2-metadata-token: $TOKEN" http://169.254.169.254/latest/meta-data/instance-id)
    AZ=$(curl -s -H "X-aws-ec2-metadata-token: $TOKEN" http://169.254.169.254/latest/meta-data/placement/availability-zone)
    mkdir -p /srv/web
    echo "<h1>${var.name}</h1><p>Instance $ID in $AZ</p>" > /srv/web/index.html
    systemd-run --unit=web --working-directory=/srv/web python3 -m http.server 80
  EOT
  )

  metadata_options {
    http_tokens = "required"
  }

  block_device_mappings {
    device_name = "/dev/xvda"

    ebs {
      volume_size = 8
      volume_type = "gp3"
      encrypted   = true
    }
  }

  tag_specifications {
    resource_type = "instance"

    tags = {
      Name = "${var.name}-web"
    }
  }
}

# COST: min_size instances run at all times.
resource "aws_autoscaling_group" "web" {
  name_prefix         = "${var.name}-"
  min_size            = var.min_size
  max_size            = var.max_size
  vpc_zone_identifier = module.vpc.private_subnet_ids # spread across AZs
  target_group_arns   = [aws_lb_target_group.web.arn]

  # Replace instances that fail the LOAD BALANCER health check, not just
  # the basic EC2 status check.
  health_check_type         = "ELB"
  health_check_grace_period = 60

  launch_template {
    id      = aws_launch_template.web.id
    version = aws_launch_template.web.latest_version
  }

  # When the launch template changes, gradually replace instances while
  # keeping at least half of them in service.
  instance_refresh {
    strategy = "Rolling"

    preferences {
      min_healthy_percentage = 50
    }
  }

  lifecycle {
    # desired_capacity is managed by the scaling policy at runtime; do
    # not let Terraform fight it on every apply.
    ignore_changes = [desired_capacity]
  }
}

# Target tracking: AWS creates and manages the CloudWatch alarms needed
# to keep average CPU near the target.
resource "aws_autoscaling_policy" "cpu" {
  name                   = "${var.name}-cpu-target"
  autoscaling_group_name = aws_autoscaling_group.web.name
  policy_type            = "TargetTrackingScaling"

  target_tracking_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ASGAverageCPUUtilization"
    }
    target_value = var.target_cpu_percent
  }
}
