[⬆ RDS](../README.md) | [🏠 Home](../../../README.md) | [📚 Learning Path](../../../docs/00-learning-roadmap/README.md)

# Lab · Basic PostgreSQL on RDS

🟡 Intermediate · [RDS track](../README.md) · 💰 **Billed per hour** (`db.t4g.micro`) plus 20 GiB storage and backups. Creating and deleting each take several minutes. **Destroy as soon as you are done.**

## What will be created

| Resource | Settings |
| --- | --- |
| `aws_db_subnet_group.this` | All default-VPC subnets |
| `aws_security_group.db` + ingress rule | 5432 from the VPC CIDR only |
| `aws_db_instance.this` | PostgreSQL `var.engine_version` (17), `db.t4g.micro`, 20 GiB gp3, encrypted, private, 1-day backups, master password managed by RDS in Secrets Manager |

**Learning shortcuts** in this lab (commented in the code): `skip_final_snapshot = true`, `deletion_protection = false`, single-AZ.

## Commands

```bash
terraform init
terraform apply          # ~5–10 minutes
terraform output
```

## Verification

```bash
aws rds describe-db-instances \
  --query "DBInstances[?starts_with(DBInstanceIdentifier,'tf-learning-')].[DBInstanceIdentifier,DBInstanceStatus,Engine,EngineVersion,PubliclyAccessible,StorageEncrypted]" \
  --output table

# The generated password lives in Secrets Manager, not in Terraform state:
aws secretsmanager describe-secret --secret-id "$(terraform output -raw master_user_secret_arn)" \
  --query "[Name,OwningService]"
```

Terraform only records the secret's **ARN** (`master_user_secret`), never the password itself.

To connect, you need a client inside the VPC (e.g. an SSM session on [EC2 lab 01](../../ec2/01-instance-with-ssm/README.md), then install a PostgreSQL client — `dnf search postgresql` lists the available versions), and the password from Secrets Manager.

## Cleanup

```bash
terraform destroy        # no final snapshot (lab shortcut); the managed secret is removed by RDS
```

---

[⬆ RDS](../README.md) | [🏠 Home](../../../README.md) | [📚 Learning Path](../../../docs/00-learning-roadmap/README.md)
