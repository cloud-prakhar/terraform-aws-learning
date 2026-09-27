[← 09 · Meta-Arguments](../09-meta-arguments/README.md) | [🏠 Home](../../README.md) | [📚 Learning Path](../00-learning-roadmap/README.md) | [AWS Service Tracks →](../../aws-services/README.md)

# 10 · Expressions and Functions

🟡 Intermediate · ⏱️ 60 minutes · 💰 No AWS cost — practise in the HCL playground

[Chapter 04](../04-hcl-fundamentals/README.md) introduced expressions. This chapter goes deeper into the tools you will use in every real configuration: `for` expressions, splats, conditionals, `dynamic` blocks, templates and the most useful built-in functions.

**Practice:** [examples/beginner/00-hcl-playground](../../examples/beginner/00-hcl-playground/README.md) — keep `terraform console` open while reading.

---

## 1. Conditional expressions

```hcl
condition ? true_value : false_value
```

Typical AWS uses:

```hcl
instance_type = var.environment == "prod" ? "t3.medium" : "t3.micro"
count         = var.enable_nat_gateway ? 1 : 0                          # optional resource
sse_algorithm = var.kms_key_arn == null ? "AES256" : "aws:kms"         # from modules/s3
```

Both branches must produce compatible types. For **choices among more than two values**, a map lookup is clearer than nested conditionals:

```hcl
locals {
  size = {
    dev     = "t3.micro"
    staging = "t3.small"
    prod    = "t3.medium"
  }[var.environment]
}
```

---

## 2. `for` expressions in depth

```hcl
[for ITEM in COLLECTION : RESULT]                 # → list
[for ITEM in COLLECTION : RESULT if CONDITION]    # → filtered list
{for ITEM in COLLECTION : KEY => VALUE}           # → map
[for KEY, VALUE in MAP : ...]                     # iterate over a map
[for INDEX, ITEM in LIST : ...]                   # iterate with index
```

### Practical AWS patterns

**Subnet plan from a list of AZs** (from [aws-services/vpc](../../aws-services/vpc/README.md)):

```hcl
locals {
  azs = ["us-east-1a", "us-east-1b"]
  public_subnets = { for i, az in local.azs : az => cidrsubnet("10.0.0.0/16", 8, i) }
  # { "us-east-1a" = "10.0.0.0/24", "us-east-1b" = "10.0.1.0/24" }
}
```

**Map of outputs from a `for_each` resource:**

```hcl
output "bucket_arns" {
  value = { for name, bucket in aws_s3_bucket.this : name => bucket.arn }
}
```

**Flattening nested data** — tiers × AZs into one map (from [Project 02](../../projects/02-custom-vpc/README.md)):

```hcl
locals {
  tier_offsets = { public = 0, app = 4, data = 8 }
  subnets = merge([
    for tier, offset in local.tier_offsets : {
      for i, az in local.azs : "${tier}-${az}" => {
        tier = tier
        az   = az
        cidr = cidrsubnet(var.vpc_cidr, 4, offset + i)
      }
    }
  ]...)
}
```

The `...` after the list **expands** it into separate arguments: `merge(a, b, c)` instead of `merge([a, b, c])`.

**Grouping** with `...` inside a map `for`: collect values that share a key into lists:

```hcl
{ for s in var.servers : s.public ? "public" : "private" => s.name... }
# { private = ["api", "worker"], public = ["web"] }
```

---

## 3. Splat expressions

```hcl
aws_instance.worker[*].id          # count-based resource → list of IDs
var.servers[*].name                # list of objects → list of names
```

Splat does **not** work on maps (`for_each` resources). Use a `for` expression, or `values(...)`:

```hcl
values(aws_s3_bucket.this)[*].arn
```

A splat on a single, possibly-null value turns it into a zero- or one-element list, which pairs nicely with `one()`:

```hcl
one(aws_eip.nat[*].public_ip)      # the IP, or null if count = 0
```

---

## 4. `dynamic` blocks

### What is it?

`dynamic` generates **repeated nested blocks** from a collection — the nested-block equivalent of `for_each`.

### Why do we need it?

Some resources configure lists of things as nested blocks (`route`, `ingress`, `setting`, …). When the number of blocks depends on input, you can't write them by hand.

### Syntax

```hcl
resource "aws_route_table" "app" {
  vpc_id = aws_vpc.this.id

  dynamic "route" {
    # zero or one route block, depending on whether NAT is enabled
    for_each = var.nat_gateway_mode == "none" ? [] : [aws_nat_gateway.this.id]

    content {
      cidr_block     = "0.0.0.0/0"
      nat_gateway_id = route.value        # the iterator is named after the block
    }
  }
}
```

(Full example: [Project 02 main.tf](../../projects/02-custom-vpc/main.tf).)

### When not to use it

`dynamic` makes code harder to read. Prefer separate resources when the provider offers them — for example, one `aws_vpc_security_group_ingress_rule` resource per rule (with `for_each`) instead of `dynamic "ingress"` blocks inside `aws_security_group`. Use `dynamic` when there is no such alternative, or when an optional nested block must appear 0 or 1 times.

---

## 5. Strings and templates

```hcl
name = "${var.project}-${var.environment}"             # interpolation

policy = <<-EOT                                         # heredoc
  {"Version": "2012-10-17"}
EOT

greeting = "Hello, %{ if var.name != "" }${var.name}%{ else }stranger%{ endif }!"   # directive
```

### `templatefile()`

Keeps scripts and config files out of your `.tf` files and fills in values:

```hcl
user_data = templatefile("${path.module}/templates/user_data.sh.tftpl", {
  title       = var.page_title
  environment = "learning"
})
```

Inside the template, `${title}` is replaced by Terraform. To pass a literal `${...}` through to bash, escape it as `$${...}`. See [Project 03's template](../../projects/03-web-server/templates/user_data.sh.tftpl).

`path.module` is the directory of the current module — always use it for file paths so the code works no matter where Terraform is run from.

---

## 6. Built-in functions you will actually use

You cannot write your own functions in Terraform; you combine the built-in ones. Try each in `terraform console`.

| Category | Function | Example | Result |
| --- | --- | --- | --- |
| String | `format` | `format("%s-%02d", "web", 3)` | `"web-03"` |
| | `join` / `split` | `join(",", ["a", "b"])` | `"a,b"` |
| | `replace` | `replace("us-east-1a", "us-east-", "")` | `"1a"` |
| | `lower` / `upper` / `trimspace` | `lower("PROD")` | `"prod"` |
| | `startswith` / `endswith` | `endswith("ec2.amazonaws.com", ".amazonaws.com")` | `true` |
| Collection | `length` | `length(["a", "b"])` | `2` |
| | `contains` | `contains(["dev", "prod"], "qa")` | `false` |
| | `lookup` | `lookup({a = 1}, "b", 0)` | `0` |
| | `merge` | `merge({a = 1}, {b = 2})` | `{a = 1, b = 2}` |
| | `concat` / `flatten` | `flatten([["a"], ["b", "c"]])` | `["a", "b", "c"]` |
| | `keys` / `values` | `keys({a = 1, b = 2})` | `["a", "b"]` |
| | `slice` | `slice(["a", "b", "c"], 0, 2)` | `["a", "b"]` |
| | `element` | `element(["a", "b"], 3)` | `"b"` (wraps around) |
| | `zipmap` | `zipmap(["a", "b"], [1, 2])` | `{a = 1, b = 2}` |
| | `distinct` | `distinct(["a", "a", "b"])` | `["a", "b"]` |
| | `one` | `one([])` | `null` |
| Null / errors | `coalesce` | `coalesce(null, "x")` | `"x"` |
| | `try` | `try(var.config.port, 80)` | `80` if the attribute is missing |
| | `can` | `can(regex("^[a-z]+$", "abc"))` | `true` |
| Network | `cidrsubnet` | `cidrsubnet("10.0.0.0/16", 8, 2)` | `"10.0.2.0/24"` |
| | `cidrhost` | `cidrhost("10.0.1.0/24", 10)` | `"10.0.1.10"` |
| Encoding | `jsonencode` | `jsonencode({a = 1})` | `"{\"a\":1}"` |
| | `jsondecode` / `yamldecode` | `jsondecode("{\"a\":1}").a` | `1` |
| | `base64encode` | used for launch template `user_data` | |
| Files | `file` / `templatefile` / `fileset` / `filemd5` | see Projects 01 and 03 | |
| Types | `tostring` / `tonumber` / `toset` / `tolist` / `tomap` | `toset(["b", "a", "a"])` | `toset(["a", "b"])` |

### `jsonencode` vs `aws_iam_policy_document`

Both produce IAM policy JSON. This course prefers the [`aws_iam_policy_document`](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) data source for policies (clearer structure, validated keys, merges statements), and `jsonencode` for small JSON values such as SQS redrive policies.

### Functions to be careful with

- `timestamp()` returns a new value on **every** plan, causing permanent diffs. Avoid it in resource arguments.
- `uuid()` has the same problem.
- `file()` reads at **plan** time; the file must exist before `terraform plan`.

---

## Exercises (in the playground console)

1. Build `{ "web" = "web-01", "api" = "api-01" }` from `var.servers` with `for` and `format`.
2. Produce the list of subnet CIDRs `10.0.10.0/24`, `10.0.11.0/24`, `10.0.12.0/24` with `for` and `cidrsubnet`.
3. Group server names by whether they are public (use the grouping `...` syntax).
4. Use `try` to read `var.servers[5].name` with a fallback of `"none"`.

<details>
<summary>Answers</summary>

1. `{ for s in var.servers : s.name => format("%s-%02d", s.name, 1) if s.name != "worker" }`
2. `[for i in range(3) : cidrsubnet("10.0.0.0/16", 8, i + 10)]`
3. `{ for s in var.servers : (s.public ? "public" : "private") => s.name... }`
4. `try(var.servers[5].name, "none")`

</details>

---

## Key takeaways

- `for` expressions transform and filter collections; `...` expands a list into arguments or groups map values.
- Splat is shorthand for lists; use `for` or `values()` for maps.
- `dynamic` generates nested blocks — use it only when separate resources aren't available.
- `templatefile` + `path.module` keeps scripts out of `.tf` files.

## Official references

- [Expressions](https://developer.hashicorp.com/terraform/language/expressions)
- [for expressions](https://developer.hashicorp.com/terraform/language/expressions/for)
- [Splat expressions](https://developer.hashicorp.com/terraform/language/expressions/splat)
- [dynamic blocks](https://developer.hashicorp.com/terraform/language/expressions/dynamic-blocks)
- [String templates](https://developer.hashicorp.com/terraform/language/expressions/strings)
- [Built-in functions](https://developer.hashicorp.com/terraform/language/functions)

---

[← 09 · Meta-Arguments](../09-meta-arguments/README.md) | [🏠 Home](../../README.md) | [📚 Learning Path](../00-learning-roadmap/README.md) | [AWS Service Tracks →](../../aws-services/README.md)
