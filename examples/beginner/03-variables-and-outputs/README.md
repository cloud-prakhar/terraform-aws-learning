[⬆ Examples](../../README.md) | [🏠 Home](../../../README.md) | [📚 Learning Path](../../../docs/00-learning-roadmap/README.md)

# Lab · Variables and outputs

🟢 Beginner · Used in [Chapter 07](../../../docs/07-variables-and-outputs/README.md) · 💰 **Costs money while running** (one `t3.micro` instance). The empty bucket is free.

## What will be created

| Resource | Purpose |
| --- | --- |
| `aws_instance.web` | Instance whose type, disk size, monitoring and name come from variables |
| `aws_s3_bucket.artifacts` | Bucket named from `project_name` and `environment` |

## Files

| File | What to look at |
| --- | --- |
| [variables.tf](variables.tf) | Types, defaults, validation with `contains()` and `can(regex())`, a nullable-style optional variable, a map of extra tags |
| [main.tf](main.tf) | `coalesce()` for an optional name, `merge()` for tags |
| [outputs.tf](outputs.tf) | Simple, attribute and composite outputs |
| [terraform.tfvars.example](terraform.tfvars.example) | Template for `terraform.tfvars` (which is git-ignored) |

## Commands

```bash
cp terraform.tfvars.example terraform.tfvars
terraform init
terraform plan
terraform plan -var environment=qa           # expect a validation error
terraform plan -var instance_name=my-server  # see the Name tag change
terraform apply
terraform output
terraform output -raw bucket_name
terraform output -json
```

## Expected result

`Plan: 2 to add`. After apply, six outputs are printed, including `connection_hint`, which combines several attributes into one sentence.

## Verification

```bash
aws ec2 describe-instances --instance-ids "$(terraform output -raw instance_id)" \
  --query "Reservations[0].Instances[0].Tags" --region us-east-1
```

The tags include `Environment`, `Name`, your `extra_tags`, and the provider's `default_tags` (`Project`, `Lab`, `ManagedBy`).

## Cleanup

```bash
terraform destroy
rm terraform.tfvars   # optional
```

---

[⬆ Examples](../../README.md) | [🏠 Home](../../../README.md) | [📚 Learning Path](../../../docs/00-learning-roadmap/README.md)
