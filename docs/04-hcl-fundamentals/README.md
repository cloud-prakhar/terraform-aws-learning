[← 03 · Terraform Basics](../03-terraform-basics/README.md) | [🏠 Home](../../README.md) | [📚 Learning Path](../00-learning-roadmap/README.md) | [05 · Terraform Workflow →](../05-terraform-workflow/README.md)

# 04 · HCL Fundamentals

🟢 Beginner · ⏱️ 60 minutes · 💰 No AWS cost — the lab never talks to AWS

HCL (HashiCorp Configuration Language) is the language `.tf` files are written in. By the end of this chapter you can read any Terraform file and know which parts are blocks, arguments, values and expressions.

**Lab:** [examples/beginner/00-hcl-playground](../../examples/beginner/00-hcl-playground/README.md). Keep a terminal open there and try every example in `terraform console`.

```bash
cd examples/beginner/00-hcl-playground
terraform init
terraform console
> 1 + 2
3
> upper("hello")
"HELLO"
> exit
```

---

## 1. Blocks, arguments and identifiers

### What is it?

HCL has only two structural elements:

- A **block** is a container: a *type*, zero or more *labels*, and a body in `{ }`.
- An **argument** assigns a value to a name inside a block: `name = value`.

```hcl
resource "aws_instance" "web" {      # block: type "resource", labels "aws_instance" and "web"
  instance_type = "t3.micro"          # argument
  ami           = data.aws_ami.al2023.id

  root_block_device {                 # nested block (no labels)
    encrypted = true
  }
}
```

**Identifiers** (names such as `web`, `instance_type`) may contain letters, digits, underscores and hyphens, and must not start with a digit. The convention is `snake_case`.

### Argument vs nested block

The provider documentation tells you whether something is an argument (`tags = { ... }`, with `=`) or a block (`root_block_device { ... }`, without `=`). Mixing them up is a common beginner error: `root_block_device = { ... }` fails.

### Comments

```hcl
# single line (preferred style)
// single line (also valid)
/* multi-line
   comment */
```

---

## 2. Types and values

| Type | Example | Notes |
| --- | --- | --- |
| `string` | `"t3.micro"` | Always double quotes |
| `number` | `8`, `0.5` | Integers and decimals share one type |
| `bool` | `true`, `false` | No quotes |
| `list(...)` / tuple | `["us-east-1a", "us-east-1b"]` | Ordered; access by index `[0]` |
| `set(...)` | `toset(["80", "443"])` | Unordered, no duplicates; **no** index access |
| `map(...)` | `{ dev = "t3.micro", prod = "t3.medium" }` | Keys are strings; values share one type |
| `object({...})` | `{ name = "web", size_gb = 20 }` | Named attributes, each with its own type |
| `null` | `null` | "No value" — the argument behaves as if it was not set |

A **tuple** is the value type of a literal `[...]` and may mix types (`["web", 2, true]`); a **list** has one element type. Terraform converts between them automatically in most places, so beginners can treat both as "lists".

Try in the console:

```text
> local.unique_ports
toset([
  22,
  80,
  443,
])
> var.instance_types["prod"]
"t3.medium"
> var.servers[0].name
"web"
```

### Multi-line strings: heredoc

```hcl
user_data = <<-EOT
  #!/bin/bash
  echo "hello" > /tmp/hello.txt
EOT
```

`<<-` strips leading indentation, so the script can be indented with the code.

---

## 3. References

A **reference** reads a value from somewhere else in the configuration:

| Syntax | Reads | Chapter |
| --- | --- | --- |
| `aws_s3_bucket.logs.arn` | An attribute of a resource | 03 |
| `data.aws_caller_identity.current.account_id` | An attribute of a data source | 08 |
| `var.environment` | An input variable | 07 |
| `local.common_tags` | A local value | 08 |
| `module.vpc.vpc_id` | An output of a module | 13 |
| `path.module` | The directory of the current module | 10 |
| `terraform.workspace` | The current workspace name | 14 |

Every resource/data reference also **creates a dependency** — this is how Terraform builds its graph ([Chapter 01](../01-terraform-introduction/README.md#6-the-dependency-graph)).

---

## 4. Expressions

An **expression** is anything that produces a value. You have already seen literals and references. The most useful others:

### String interpolation

```hcl
name = "${var.project_name}-${var.environment}-web"   # "tf-learning-dev-web"
```

### Operators

```hcl
count        = var.enable_backup ? 1 : 0            # conditional
is_prod      = var.environment == "prod"            # comparison → bool
needs_backup = local.is_prod && var.has_data        # logic: &&, ||, !
disk_total   = var.root_gb + var.data_gb            # arithmetic
```

### Conditional expression

`condition ? value_if_true : value_if_false`

```hcl
instance_type = var.environment == "prod" ? "t3.medium" : "t3.micro"
```

Both result values should have the same type.

### Function calls

Terraform has many **built-in** functions (you cannot define your own):

```hcl
upper("web")                                  # "WEB"
length(["a", "b", "c"])                       # 3
merge({ a = 1 }, { b = 2 })                   # { a = 1, b = 2 }
cidrsubnet("10.0.0.0/16", 8, 1)               # "10.0.1.0/24"
coalesce(null, "fallback")                    # "fallback"
```

### `for` expressions

Transform one collection into another:

```hcl
[for s in var.servers : upper(s.name)]                 # list → list
[for s in var.servers : s.name if s.public]            # with a filter
{ for s in var.servers : s.name => s.size_gb }         # list → map
```

### Splat expressions

A shorthand for "this attribute from every element":

```hcl
var.servers[*].name         # same as [for s in var.servers : s.name]
aws_instance.web[*].id      # all IDs of a resource that uses count
```

Functions, `for`, splat and `dynamic` blocks get a full chapter in [Chapter 10](../10-expressions-and-functions/README.md).

---

## 5. Lab: the HCL playground

**Folder:** [examples/beginner/00-hcl-playground](../../examples/beginner/00-hcl-playground/README.md)

The playground has **no provider**, so it is free and needs no credentials. It defines variables of every type in `variables.tf` and many expressions as `locals` in `main.tf`.

```bash
cd examples/beginner/00-hcl-playground
terraform init
terraform plan              # shows all outputs, creates nothing
terraform console
```

Try these in the console and predict each answer before pressing Enter:

```text
> local.name_prefix
> local.instance_type
> local.public_server_names
> local.disk_size_by_server
> local.subnet_cidrs
> local.web_tags
> [for az in var.availability_zones : replace(az, "us-east-", "")]
> { for k, v in var.instance_types : v => k }
```

Then change the environment and watch the conditionals change:

```bash
terraform console -var environment=prod
> local.instance_type
```

And trigger a validation error on purpose:

```bash
terraform plan -var environment=qa
```

### Cleanup

Nothing to destroy. Delete the local `.terraform/` folder if you like.

---

## Key takeaways

- HCL is **blocks** (containers) and **arguments** (`name = value`).
- Values have **types**: string, number, bool, list/tuple, set, map, object, null.
- **References** connect blocks and create dependencies.
- `terraform console` is the fastest way to experiment with expressions.

## Official references

- [Configuration syntax](https://developer.hashicorp.com/terraform/language/syntax/configuration)
- [Types and values](https://developer.hashicorp.com/terraform/language/expressions/types)
- [Expressions overview](https://developer.hashicorp.com/terraform/language/expressions)
- [terraform console](https://developer.hashicorp.com/terraform/cli/commands/console)

---

[← 03 · Terraform Basics](../03-terraform-basics/README.md) | [🏠 Home](../../README.md) | [📚 Learning Path](../00-learning-roadmap/README.md) | [05 · Terraform Workflow →](../05-terraform-workflow/README.md)
