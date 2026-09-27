[⬆ Lambda](../README.md) | [🏠 Home](../../../README.md) | [📚 Learning Path](../../../docs/00-learning-roadmap/README.md)

# Lab · Scheduled Lambda function

🟡 Intermediate · [Lambda track](../README.md) · 💰 Per use: one short invocation per hour

## What will be created

| Resource | Purpose |
| --- | --- |
| `data.archive_file.function` | Zips [src/handler.py](src/handler.py) into `build/function.zip` (git-ignored) |
| `aws_cloudwatch_log_group.function` | `/aws/lambda/tf-learning-heartbeat`, 14 days |
| `aws_iam_role.function` + `aws_iam_role_policy.logs` | Execution role that may write **only to its own** log group |
| `aws_lambda_function.this` | Python 3.13 on arm64, env var `GREETING` |
| `aws_cloudwatch_event_rule.schedule` + `aws_cloudwatch_event_target.function` | EventBridge schedule `rate(1 hour)` |
| `aws_lambda_permission.eventbridge` | Lets **only that rule** invoke the function |

This lab uses a second provider, `hashicorp/archive`, declared in [versions.tf](versions.tf).

## Commands

```bash
terraform init
terraform apply
$(terraform output -raw invoke_command)    # invoke it manually
```

## Verification

```bash
aws logs tail "$(terraform output -raw log_group)" --since 10m
```

You should see a JSON line with `"greeting": "Hello from Terraform"`.

## Experiments

1. `terraform apply -var greeting="Hi"` → only the function's configuration changes (update in place).
2. Edit `src/handler.py` (e.g. add a field) and plan: `source_code_hash` changes, so the code is redeployed.

## Cleanup

```bash
terraform destroy
```

---

[⬆ Lambda](../README.md) | [🏠 Home](../../../README.md) | [📚 Learning Path](../../../docs/00-learning-roadmap/README.md)
