[⬆ Terraform on AWS](../README.md) | [🏠 Home](../README.md) | [📚 Learning Path](../docs/00-learning-roadmap/README.md)

# Cheatsheet · Modules

Lesson: [Ch. 13](../docs/13-terraform-modules/README.md) · Examples: [modules/](../modules/README.md)

## Call

```hcl
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"     # registry
  version = "~> 6.7"                            # always pin
  name    = "demo"
}

module "bucket" {
  source        = "../../modules/s3"            # local path
  for_each      = toset(["logs", "data"])       # count/for_each/depends_on/providers work too
  bucket_prefix = "demo-${each.key}-"
}

# module.vpc.vpc_id   module.bucket["logs"].bucket_arn
```

Run `terraform init` after adding or changing `source`.

## Sources

| Kind | Example |
| --- | --- |
| Local | `./modules/s3`, `../../modules/vpc` |
| Registry | `terraform-aws-modules/vpc/aws` + `version` |
| Git | `git::https://github.com/org/repo.git//path?ref=v1.2.0` |
| Private registry | `app.terraform.io/org/name/aws` + `version` |

## Write

```text
my-module/
├── main.tf  variables.tf  outputs.tf  versions.tf
├── README.md             # + terraform-docs section
├── examples/basic/
└── tests/*.tftest.hcl
```

- `versions.tf`: `required_providers { aws = { source = "hashicorp/aws", version = ">= 6.0" } }` — a minimum, no upper pin.
- No `provider` blocks inside modules.
- Typed, described, validated variables; secure defaults.
- Output IDs/ARNs callers need.
- Refactoring internals → add `moved` blocks in the module.

## Version your own

| Change | SemVer |
| --- | --- |
| Remove/rename an input or output | major |
| New optional input / new output | minor |
| Bug fix, no interface change | patch |

## Docs and tests

```bash
terraform-docs modules/s3
terraform -chdir=modules/s3 test
```

---

[⬆ Terraform on AWS](../README.md) | [🏠 Home](../README.md) | [📚 Learning Path](../docs/00-learning-roadmap/README.md)
