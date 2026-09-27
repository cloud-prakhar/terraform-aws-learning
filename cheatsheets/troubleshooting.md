[⬆ Terraform on AWS](../README.md) | [🏠 Home](../README.md) | [📚 Learning Path](../docs/00-learning-roadmap/README.md)

# Cheatsheet · Troubleshooting

Full guide: [Ch. 22](../docs/22-troubleshooting/README.md)

**First, always:** `aws sts get-caller-identity` · `terraform version` · `terraform workspace show`

| Error (fragment) | Likely cause | Fix |
| --- | --- | --- |
| `No valid credential sources found` | No/expired credentials | `aws sso login`; `export AWS_PROFILE=...` |
| `ExpiredToken` | SSO/assumed session expired | Log in again |
| `AccessDenied` / `UnauthorizedOperation` | Missing IAM permission, SCP, resource policy | Read action + ARN in the message; `aws sts decode-authorization-message` |
| `no matching ... found` (data source) | Wrong Region/filters | Check `var.aws_region`, filters |
| `Failed to query available provider packages` | Network/proxy/typo in `source` | Fix source/proxy |
| `does not match configured version constraint` | Lock file vs constraints | `terraform init -upgrade`, commit lock |
| `Module not installed` | New/changed module | `terraform init` |
| `No value for required variable` | Missing input | tfvars / `-var` / `TF_VAR_` |
| `Invalid value for input variable` | Type mismatch | Match `type`; HCL syntax for complex values |
| `Invalid count argument` / `Invalid for_each argument` | Keys unknown until apply | Static keys; unknown values in map values |
| `Cycle:` | Mutual references | Split resources; separate SG rule resources |
| `BucketAlreadyExists` / `EntityAlreadyExists` | Exists outside state / name taken | `import` block, or new name |
| `InvalidAMIID.NotFound` / architecture mismatch | Hard-coded AMI / ARM vs x86 | `data "aws_ami"` with `owners` + matching arch |
| `Error acquiring the state lock` | Another run / stale lock | Wait; `force-unlock` only if nothing runs |
| `Backend initialization required` | Backend added/changed | `terraform init [-migrate-state \| -reconfigure]` |
| `Instance cannot be destroyed` | `prevent_destroy` | Intended protection — change code deliberately |
| `Not authorized to perform sts:AssumeRoleWithWebIdentity` | OIDC `sub`/`aud` mismatch, missing `id-token: write` | Align trust policy with job context |
| `DependencyViolation` (security group) | Still attached | Remove dependents; `create_before_destroy` |

Debug: `TF_LOG=DEBUG terraform plan 2> debug.log` (may contain secrets).

---

[⬆ Terraform on AWS](../README.md) | [🏠 Home](../README.md) | [📚 Learning Path](../docs/00-learning-roadmap/README.md)
