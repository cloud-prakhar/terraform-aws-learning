# Three security groups for a classic three-tier app. Each tier only
# accepts traffic from the tier in front of it, identified by SECURITY
# GROUP rather than by IP address. Instances can come and go (auto
# scaling) without any rule changes.
#
#   internet --80/443--> alb --8080--> app --5432--> db
#
# Security groups themselves are free, so this lab costs nothing.

data "aws_vpc" "default" {
  default = true
}

resource "aws_security_group" "alb" {
  name        = "tf-learning-alb"
  description = "Load balancer: HTTP/HTTPS from the internet"
  vpc_id      = data.aws_vpc.default.id
}

resource "aws_security_group" "app" {
  name        = "tf-learning-app"
  description = "Application servers: traffic from the load balancer only"
  vpc_id      = data.aws_vpc.default.id
}

resource "aws_security_group" "db" {
  name        = "tf-learning-db"
  description = "Database: PostgreSQL from application servers only"
  vpc_id      = data.aws_vpc.default.id
}

# --- Ingress rules: one resource per rule -------------------------------

resource "aws_vpc_security_group_ingress_rule" "alb_http" {
  security_group_id = aws_security_group.alb.id
  description       = "HTTP from anywhere"
  ip_protocol       = "tcp"
  from_port         = 80
  to_port           = 80
  cidr_ipv4         = "0.0.0.0/0"
}

resource "aws_vpc_security_group_ingress_rule" "alb_https" {
  security_group_id = aws_security_group.alb.id
  description       = "HTTPS from anywhere"
  ip_protocol       = "tcp"
  from_port         = 443
  to_port           = 443
  cidr_ipv4         = "0.0.0.0/0"
}

resource "aws_vpc_security_group_ingress_rule" "app_from_alb" {
  security_group_id            = aws_security_group.app.id
  description                  = "App port from the load balancer"
  ip_protocol                  = "tcp"
  from_port                    = 8080
  to_port                      = 8080
  referenced_security_group_id = aws_security_group.alb.id
}

resource "aws_vpc_security_group_ingress_rule" "db_from_app" {
  security_group_id            = aws_security_group.db.id
  description                  = "PostgreSQL from the app tier"
  ip_protocol                  = "tcp"
  from_port                    = 5432
  to_port                      = 5432
  referenced_security_group_id = aws_security_group.app.id
}

# --- Egress rules -----------------------------------------------------
# Security groups created by Terraform start with NO egress rules
# (Terraform removes AWS's default allow-all rule), so outbound traffic
# must be allowed explicitly.

resource "aws_vpc_security_group_egress_rule" "alb_to_app" {
  security_group_id            = aws_security_group.alb.id
  description                  = "Forward requests to the app tier"
  ip_protocol                  = "tcp"
  from_port                    = 8080
  to_port                      = 8080
  referenced_security_group_id = aws_security_group.app.id
}

resource "aws_vpc_security_group_egress_rule" "app_all" {
  security_group_id = aws_security_group.app.id
  description       = "App servers may call out (updates, AWS APIs, DB)"
  ip_protocol       = "-1"
  cidr_ipv4         = "0.0.0.0/0"
}

# The db group has no egress rule on purpose. Security groups are
# STATEFUL: replies to allowed inbound connections are always permitted,
# so the database can answer queries without any egress rule.
