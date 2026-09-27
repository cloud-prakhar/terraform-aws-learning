[⬆ Meta-argument labs](../README.md) | [🏠 Home](../../../README.md) | [📚 Learning Path](../../../docs/00-learning-roadmap/README.md)

# Lab · count and for_each

🟡 Intermediate · [Chapter 09](../../../docs/09-meta-arguments/README.md#1-count) · 💰 **Costs money while running** (2 × `t3.micro`)

## What will be created

| Address | How many | Why this meta-argument |
| --- | --- | --- |
| `aws_instance.worker[0..N-1]` | `var.instance_count` (default 2) | Identical copies → `count` |
| `aws_s3_bucket.this["logs" / "artifacts" / "backups"]` | one per map key | Named copies with different settings → `for_each` |
| `aws_s3_bucket_versioning.this[...]` | one per bucket | `for_each = aws_s3_bucket.this` (chaining) |

## Commands

```bash
terraform init
terraform apply
terraform state list                  # see [0], [1] and ["logs"] style addresses
terraform output
```

## Experiments

1. `terraform plan -var instance_count=3` → one instance **added** at `[2]`.
2. `terraform plan -var instance_count=1` → `[1]` **destroyed** (the last index goes first).
3. In [variables.tf](variables.tf) remove the `artifacts` entry from `buckets` and plan: only `["artifacts"]` and its versioning resource are destroyed.
4. `terraform console` → `aws_instance.worker[*].id`, `keys(aws_s3_bucket.this)`.

## Verification

```bash
aws ec2 describe-instances --filters "Name=tag:Lab,Values=meta-count-for-each" "Name=instance-state-name,Values=running" \
  --query "Reservations[].Instances[].Tags[?Key=='Name'].Value" --output text
```

## Cleanup

```bash
terraform destroy
```

---

[⬆ Meta-argument labs](../README.md) | [🏠 Home](../../../README.md) | [📚 Learning Path](../../../docs/00-learning-roadmap/README.md)
