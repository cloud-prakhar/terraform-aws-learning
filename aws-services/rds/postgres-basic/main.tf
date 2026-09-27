# COST WARNING: RDS instances are billed per hour plus storage and
# backups. Creating one takes several minutes. Destroy it after the lab.

data "aws_vpc" "default" {
  default = true
}

data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

# RDS needs subnets in at least two AZs, even for a single-AZ database,
# so it can move or fail over the instance later.
resource "aws_db_subnet_group" "this" {
  name_prefix = "tf-learning-"
  subnet_ids  = data.aws_subnets.default.ids
}

resource "aws_security_group" "db" {
  name_prefix = "tf-learning-db-"
  description = "PostgreSQL from inside the VPC only"
  vpc_id      = data.aws_vpc.default.id
}

resource "aws_vpc_security_group_ingress_rule" "postgres" {
  security_group_id = aws_security_group.db.id
  description       = "PostgreSQL from the VPC"
  ip_protocol       = "tcp"
  from_port         = 5432
  to_port           = 5432
  cidr_ipv4         = data.aws_vpc.default.cidr_block
}

resource "aws_db_instance" "this" {
  identifier_prefix = "tf-learning-"
  engine            = "postgres"
  engine_version    = var.engine_version
  instance_class    = var.instance_class

  allocated_storage = 20
  storage_type      = "gp3"
  storage_encrypted = true

  db_name  = "app"
  username = "app_admin"

  # RDS generates the master password and stores it in Secrets Manager.
  # Terraform never sees the password, so it is not in state.
  manage_master_user_password = true

  db_subnet_group_name   = aws_db_subnet_group.this.name
  vpc_security_group_ids = [aws_security_group.db.id]
  publicly_accessible    = false
  multi_az               = false # production: true, for a standby in another AZ

  copy_tags_to_snapshot      = true
  backup_retention_period    = 1
  auto_minor_version_upgrade = true
  deletion_protection        = var.deletion_protection

  # LEARNING SHORTCUT: no final snapshot on destroy. In production keep
  # skip_final_snapshot = false and set final_snapshot_identifier.
  skip_final_snapshot = true
}
