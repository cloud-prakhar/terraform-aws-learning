[⬆ Terraform on AWS](../README.md) | [🏠 Home](../README.md) | [📚 Learning Path](../docs/00-learning-roadmap/README.md)

# Cheatsheet · Variables, Locals and Outputs

Lessons: [Ch. 07](../docs/07-variables-and-outputs/README.md) · [Ch. 08](../docs/08-data-sources-and-locals/README.md)

## Declare

```hcl
variable "environment" {
  description = "Environment name."
  type        = string
  default     = "dev"            # omit → required
  sensitive   = false            # true → redacted in CLI output (still in state!)
  nullable    = true             # false → passing null uses the default

  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "environment must be dev, staging or prod."
  }
}
```

## Set (lowest → highest precedence)

1. `default` in the variable block
2. `TF_VAR_environment=prod` environment variable
3. `terraform.tfvars`
4. `terraform.tfvars.json`
5. `*.auto.tfvars` / `*.auto.tfvars.json` (alphabetical)
6. `-var 'environment=prod'` and `-var-file=prod.tfvars` (command-line order)

Complex values in HCL syntax: `-var 'tags={Owner="alice"}'`, `TF_VAR_azs='["us-east-1a","us-east-1b"]'`.

## Locals

```hcl
locals {
  name_prefix = "${var.project}-${var.environment}"
  common_tags = { Project = var.project, Environment = var.environment }
}
# local.name_prefix
```

## Outputs

```hcl
output "bucket_arn" {
  description = "ARN of the bucket."
  value       = aws_s3_bucket.this.arn
  sensitive   = false
}
```

```bash
terraform output              # all
terraform output -raw NAME    # plain string
terraform output -json        # prints sensitive values in clear text!
```

## Which one?

| | Variable | Local | Output |
| --- | --- | --- | --- |
| Is | input | internal value | result |
| Read as | `var.x` | `local.x` | `module.m.x` / `terraform output x` |

## Secrets

- Never put real secrets in `default`, tfvars in Git, or outputs.
- `sensitive = true` hides, doesn't protect. Prefer managed passwords, ephemeral resources and write-only arguments (`*_wo`).

---

[⬆ Terraform on AWS](../README.md) | [🏠 Home](../README.md) | [📚 Learning Path](../docs/00-learning-roadmap/README.md)
