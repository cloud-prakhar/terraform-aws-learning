[⬆ Secrets Manager](../README.md) | [🏠 Home](../../../README.md) | [📚 Learning Path](../../../docs/00-learning-roadmap/README.md)

# Lab · A secret that never enters Terraform state

🟡 Intermediate · [Secrets Manager track](../README.md) · 💰 One secret: small **monthly charge** (prorated) plus API calls

## What will be created

| Block | Purpose |
| --- | --- |
| `aws_secretsmanager_secret.db` | The container `tf-learning/app/db-password` |
| `ephemeral "aws_secretsmanager_random_password" "db"` | Generates a 32-character password during the run only |
| `aws_secretsmanager_secret_version.db` | Stores it through the **write-only** `secret_string_wo` |
| `aws_iam_policy.read_secret` | Allows `GetSecretValue` on this one secret — attach to an app's role |

Requires **Terraform 1.11+**.

## Commands

```bash
terraform init
terraform apply
terraform output
```

## Verification

**1 · The secret has a value in AWS:**

```bash
aws secretsmanager get-secret-value --secret-id tf-learning/app/db-password \
  --query "SecretString" --output text | wc -c        # 33 = 32 characters + newline
```

**2 · The value is NOT in Terraform state:**

```bash
terraform state show aws_secretsmanager_secret_version.db
# has_secret_string_wo = true, but no password value is recorded
terraform state pull | grep -c "$(aws secretsmanager get-secret-value \
  --secret-id tf-learning/app/db-password --query SecretString --output text)"   # 0
```

**3 · Rotate through Terraform:**

```bash
terraform apply -var password_version=2     # generates and stores a new value
aws secretsmanager list-secret-version-ids --secret-id tf-learning/app/db-password \
  --query "Versions[].[VersionId,VersionStages]"
```

## Cleanup

```bash
terraform destroy     # recovery_window_in_days = 0 → deleted immediately (lab shortcut)
```

---

[⬆ Secrets Manager](../README.md) | [🏠 Home](../../../README.md) | [📚 Learning Path](../../../docs/00-learning-roadmap/README.md)
