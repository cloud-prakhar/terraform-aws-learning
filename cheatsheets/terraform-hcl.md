[⬆ Terraform on AWS](../README.md) | [🏠 Home](../README.md) | [📚 Learning Path](../docs/00-learning-roadmap/README.md)

# Cheatsheet · HCL Syntax

Lessons: [Ch. 04](../docs/04-hcl-fundamentals/README.md) · [Ch. 10](../docs/10-expressions-and-functions/README.md)

## Blocks

```hcl
terraform { required_version = ">= 1.11.0" }
provider "aws" { region = "us-east-1" }
resource "aws_s3_bucket" "logs" { bucket_prefix = "logs-" }
data "aws_caller_identity" "current" {}
variable "env" { type = string }
locals { name = "app-${var.env}" }
output "arn" { value = aws_s3_bucket.logs.arn }
module "vpc" { source = "./modules/vpc" }
```

## Types

```hcl
"text"                      # string
42  3.14                    # number
true  false                 # bool
["a", "b"]                  # list / tuple
toset(["a", "b"])           # set
{ a = 1, b = 2 }            # map / object
null                        # no value
```

Type constraints: `string`, `number`, `bool`, `list(string)`, `set(string)`, `map(number)`, `object({ name = string, size = optional(number, 8) })`, `tuple([string, number])`, `any`.

## References

```hcl
var.name                          local.name
aws_instance.web.id               data.aws_ami.al2023.id
module.vpc.vpc_id                 aws_instance.web[0].id      # count
aws_s3_bucket.this["logs"].arn    # for_each
path.module   path.root   terraform.workspace
count.index   each.key   each.value   self (in conditions/provisioners)
```

## Expressions

```hcl
"${var.app}-${var.env}"                          # interpolation
var.env == "prod" ? "t3.medium" : "t3.micro"     # conditional
[for s in var.list : upper(s)]                   # list for
[for s in var.list : s if s != ""]               # filter
{ for k, v in var.map : k => v * 2 }             # map for
{ for s in var.servers : s.role => s.name... }   # grouping
var.servers[*].name                              # splat
merge([ { a = 1 }, { b = 2 } ]...)               # expand list into args
<<-EOT                                           # heredoc
  multi-line
EOT
"%{ if var.x }yes%{ else }no%{ endif }"          # template directive
```

## Dynamic block

```hcl
dynamic "route" {
  for_each = var.routes
  content {
    cidr_block = route.value.cidr
    gateway_id = route.value.gw
  }
}
```

## Frequently used functions

| Need | Function |
| --- | --- |
| Length / membership | `length()`, `contains()` |
| Maps | `merge()`, `lookup(m, k, default)`, `keys()`, `values()`, `zipmap()` |
| Lists | `concat()`, `flatten()`, `distinct()`, `slice()`, `element()`, `one()` |
| Strings | `format()`, `join()`, `split()`, `replace()`, `lower()`, `upper()`, `trimspace()`, `startswith()` |
| Null / errors | `coalesce()`, `try()`, `can()` |
| Networking | `cidrsubnet()`, `cidrhost()` |
| Encoding | `jsonencode()`, `jsondecode()`, `yamldecode()`, `base64encode()` |
| Files | `file()`, `templatefile()`, `fileset()`, `filemd5()` |
| Types | `tostring()`, `tonumber()`, `toset()`, `tolist()`, `tomap()` |

## Comments

```hcl
# preferred
// also valid
/* block */
```

---

[⬆ Terraform on AWS](../README.md) | [🏠 Home](../README.md) | [📚 Learning Path](../docs/00-learning-roadmap/README.md)
