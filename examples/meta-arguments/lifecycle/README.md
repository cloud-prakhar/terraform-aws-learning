[⬆ Meta-argument labs](../README.md) | [🏠 Home](../../../README.md) | [📚 Learning Path](../../../docs/00-learning-roadmap/README.md)

# Lab · lifecycle

🟡 Intermediate · [Chapter 09](../../../docs/09-meta-arguments/README.md#6-lifecycle) · 💰 **Costs money while running** (1 × `t3.micro`)

## What will be created

| Address | Lifecycle feature demonstrated |
| --- | --- |
| `aws_security_group.app` | `create_before_destroy` (with `name_prefix`) |
| `terraform_data.app_version` | a "version marker" holding `var.app_version` |
| `aws_instance.app` | `ignore_changes = [ami]`, `replace_triggered_by`, `precondition` |
| `aws_s3_bucket.important` | `prevent_destroy` (starts as `false`) |

## Commands

```bash
terraform init
terraform apply
```

## Experiments

**1 · create_before_destroy**
Change the security group's `description` in [main.tf](main.tf) (descriptions force replacement) and run `terraform apply`. The plan shows `+/-` (create replacement, then destroy) instead of `-/+`. The instance is switched to the new group before the old one is deleted.

**2 · replace_triggered_by**
```bash
terraform plan -var app_version=1.1.0
```
The instance is planned for replacement because `terraform_data.app_version` changes.

**3 · ignore_changes**
Nothing to do: whenever Amazon publishes a new AMI, `data.aws_ami.al2023` changes, but the plan does not propose replacing the instance.

**4 · prevent_destroy**
Set `prevent_destroy = true` on `aws_s3_bucket.important`, apply, then run `terraform plan -destroy`. The plan fails with *"Instance cannot be destroyed"*. Set it back to `false` before cleaning up.

**5 · precondition**
Change the AMI filter in `main.tf` to `al2023-ami-2023.*-arm64` and plan. The precondition fails with your own error message before anything is changed. Revert.

## Cleanup

```bash
# make sure prevent_destroy = false first
terraform destroy
```

---

[⬆ Meta-argument labs](../README.md) | [🏠 Home](../../../README.md) | [📚 Learning Path](../../../docs/00-learning-roadmap/README.md)
