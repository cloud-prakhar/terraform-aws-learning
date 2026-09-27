[⬆ Terraform on AWS](../README.md) | [🏠 Home](../README.md) | [📚 Learning Path](../docs/00-learning-roadmap/README.md)

# Cheatsheet · State

Lessons: [Ch. 11](../docs/11-terraform-state/README.md) · [Ch. 12](../docs/12-remote-state/README.md)

## Inspect

```bash
terraform state list
terraform state show ADDRESS
terraform show -json | jq '.values.root_module.resources[].address'
terraform plan -refresh-only
```

## Refactor (prefer code blocks)

| Goal | Code | CLI (legacy) |
| --- | --- | --- |
| Rename / move | `moved { from = A  to = B }` | `terraform state mv A B` |
| Forget, keep object | `removed { from = A  lifecycle { destroy = false } }` | `terraform state rm A` |
| Adopt existing | `import { to = A  id = "..." }` | `terraform import A ID` |
| Force replacement | — | `terraform apply -replace=A` |

## S3 backend

```hcl
terraform {
  backend "s3" {
    bucket       = "my-state-bucket"      # or via -backend-config
    key          = "app/dev/terraform.tfstate"
    region       = "us-east-1"
    encrypt      = true
    use_lockfile = true                   # S3-native locking (Terraform 1.10+, GA 1.11)
    # kms_key_id = "arn:aws:kms:..."      # optional CMK
    # dynamodb_table = "..."              # DEPRECATED
  }
}
```

State bucket: versioning ✔ · encryption ✔ · public access block ✔ · HTTPS-only policy ✔ · `prevent_destroy` ✔ · noncurrent-version expiry ✔

## Migrate

```bash
terraform init -migrate-state        # local ↔ S3, or bucket/key change
terraform init -reconfigure          # switch without copying
```

## Locks

```text
Error acquiring the state lock → check "Who"/"Created" → wait (-lock-timeout=5m)
→ only if nothing runs: terraform force-unlock LOCK_ID
```

## Recover

```bash
aws s3api list-object-versions --bucket B --prefix KEY
aws s3api get-object --bucket B --key KEY --version-id V old.tfstate
```

## Security

- State holds **every attribute**, including sensitive values.
- Never commit it; restrict read access; encrypt; separate per environment.

---

[⬆ Terraform on AWS](../README.md) | [🏠 Home](../README.md) | [📚 Learning Path](../docs/00-learning-roadmap/README.md)
