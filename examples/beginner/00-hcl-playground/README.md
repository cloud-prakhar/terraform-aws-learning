[⬆ Examples](../../README.md) | [🏠 Home](../../../README.md) | [📚 Learning Path](../../../docs/00-learning-roadmap/README.md)

# Lab · HCL playground

🟢 Beginner · Used in [Chapter 04](../../../docs/04-hcl-fundamentals/README.md) and [Chapter 10](../../../docs/10-expressions-and-functions/README.md) · 💰 Free — **no provider, no AWS credentials needed**

## What will be created

Nothing. This configuration only defines **variables**, **locals** and **outputs**, so you can explore HCL types and expressions with `terraform plan` and `terraform console`.

| File | Contents |
| --- | --- |
| [variables.tf](variables.tf) | Variables of type string (with validation), list, map and list of objects |
| [main.tf](main.tf) | `locals` demonstrating interpolation, conditionals, sets, tuples, `for`, splat and functions |
| [outputs.tf](outputs.tf) | Outputs that print the most interesting locals |

## Commands

```bash
terraform init
terraform plan                          # prints every output value
terraform console                       # interactive: type expressions, see results
terraform console -var environment=prod # same, with a different input
terraform plan -var environment=qa      # fails validation on purpose
```

## Exercises

1. Predict, then check: `local.public_server_names`, `local.subnet_cidrs`, `local.total_disk_gb`.
2. Write a `for` expression that returns only the servers larger than 25 GB.
3. Use `lookup(var.instance_types, "qa", "t3.nano")` — what does the third argument do?
4. Compare `var.servers[*].name` and `[for s in var.servers : s.name]`.
5. Try `cidrsubnet("10.0.0.0/16", 4, 2)` and explain the result.

<details>
<summary>Answers</summary>

2. `[for s in var.servers : s.name if s.size_gb > 25]` → `["api", "worker"]`
3. It is the default returned when the key is missing → `"t3.nano"`.
4. They return the same list; splat is a shorthand for simple attribute access.
5. `"10.0.32.0/20"`: 4 extra bits make /20 networks; network number 2 starts at 2 × 16 = 32 in the third octet.

</details>

## Cleanup

Nothing to destroy.

---

[⬆ Examples](../../README.md) | [🏠 Home](../../../README.md) | [📚 Learning Path](../../../docs/00-learning-roadmap/README.md)
