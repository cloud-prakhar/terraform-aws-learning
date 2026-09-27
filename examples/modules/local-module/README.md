[⬆ Module labs](../README.md) | [🏠 Home](../../../README.md) | [📚 Learning Path](../../../docs/00-learning-roadmap/README.md)

# Lab · Calling a local module

🟡 Intermediate · [Chapter 13](../../../docs/13-terraform-modules/README.md) · 💰 Free (empty buckets)

## What will be created

| Module call | Result |
| --- | --- |
| `module.logs_bucket` | One secure bucket from [modules/s3](../../../modules/s3/README.md) |
| `module.bucket["reports"]`, `module.bucket["scratch"]` | Two more, created with `for_each` on the module; `scratch` has versioning off |

Each module call creates **seven** resources (bucket, ownership controls, public access block, versioning, encryption, lifecycle, policy) — 21 in total from a few lines of code.

## Commands

```bash
terraform init          # installs the module (a local path: just linked)
terraform plan          # Plan: 21 to add
terraform apply
terraform state list    # note the module.bucket["reports"].aws_s3_bucket.this style addresses
terraform output
```

## Experiments

1. `terraform console` → `module.bucket["reports"].bucket_arn`
2. Try to read an internal resource: `module.logs_bucket.aws_s3_bucket.this.arn` in an output → error. Callers only see **outputs**.
3. Pass an invalid prefix: `bucket_prefix = "Bad_Name"` → the module's validation rule rejects it.

## Cleanup

```bash
terraform destroy
```

---

[⬆ Module labs](../README.md) | [🏠 Home](../../../README.md) | [📚 Learning Path](../../../docs/00-learning-roadmap/README.md)
