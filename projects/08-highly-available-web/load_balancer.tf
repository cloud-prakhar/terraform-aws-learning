# COST WARNING: an Application Load Balancer is billed per hour plus
# capacity units, and it holds public IPv4 addresses. Destroy after use.

resource "aws_lb" "web" {
  #checkov:skip=CKV2_AWS_20:LEARNING SHORTCUT: no HTTPS listener to redirect to (no domain/certificate).
  #checkov:skip=CKV_AWS_150:Lab resource that must be easy to destroy; enable deletion protection in production.
  name_prefix        = "p08-" # max 6 characters for name_prefix
  load_balancer_type = "application"
  internal           = false
  subnets            = module.vpc.public_subnet_ids # one per AZ
  security_groups    = [aws_security_group.alb.id]

  # Reject malformed HTTP headers instead of forwarding them.
  drop_invalid_header_fields = true
}

resource "aws_lb_target_group" "web" {
  #checkov:skip=CKV_AWS_378:TLS terminates at the load balancer; traffic to targets stays inside the VPC.
  name_prefix = "p08-"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = module.vpc.vpc_id

  # Faster scale-in for a lab (default is 300 s of connection draining).
  deregistration_delay = 30

  health_check {
    path                = "/"
    matcher             = "200"
    interval            = 15
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }

  lifecycle {
    create_before_destroy = true
  }
}

# LEARNING SHORTCUT: plain HTTP. Production: an HTTPS listener with an
# ACM certificate, and this listener redirecting HTTP → HTTPS.
resource "aws_lb_listener" "http" {
  #checkov:skip=CKV_AWS_2:LEARNING SHORTCUT: HTTPS needs a domain and an ACM certificate.
  #checkov:skip=CKV_AWS_103:LEARNING SHORTCUT: HTTPS needs a domain and an ACM certificate.
  load_balancer_arn = aws_lb.web.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.web.arn
  }
}
