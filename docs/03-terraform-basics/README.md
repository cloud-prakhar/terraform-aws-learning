[← 02 · Installation and Setup](../02-installation-and-setup/README.md) | [🏠 Home](../../README.md) | [📚 Learning Path](../00-learning-roadmap/README.md) | [04 · HCL Fundamentals →](../04-hcl-fundamentals/README.md)

# 03 · Terraform Basics

🟢 Beginner · ⏱️ 45 minutes · 💰 Free when destroyed (one empty S3 bucket)

By the end of this chapter you will have created and destroyed your first AWS resource with Terraform, and you will know what every file in a Terraform directory is for.

---

## 1. Providers

### What is it?

A **provider** is a plugin that teaches Terraform how to talk to one platform. The AWS provider knows every AWS API; the GitHub provider knows GitHub's API; and so on.

### Why do we need it?

Terraform Core is deliberately platform-neutral (see [Chapter 01](../01-terraform-introduction/README.md#4-terraform-architecture)). Providers are where the platform knowledge lives, and they are released independently of Terraform itself.

### Terraform syntax

Two blocks are involved:

```hcl
# 1. Which provider (and which versions) this configuration needs.
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"   # registry.terraform.io/hashicorp/aws
      version = "~> 6.0"
    }
  }
}

# 2. How to configure it.
provider "aws" {
  region = "us-east-1"
}
```

[Chapter 06](../06-aws-provider/README.md) covers version constraints and authentication in depth.

---

## 2. Resources

### What is it?

A **resource** block describes one infrastructure object that Terraform should create and manage.

```hcl
resource "aws_s3_bucket" "first" {
  bucket_prefix = "tf-learning-first-"
}
```

| Part | Meaning |
| --- | --- |
| `resource` | Block type: "manage this object" |
| `"aws_s3_bucket"` | **Resource type**. The prefix `aws_` tells Terraform which provider handles it. |
| `"first"` | **Local name**. Only meaningful inside your code; AWS never sees it. |
| `bucket_prefix = ...` | **Arguments**: settings for the object, defined by the provider |

Together, type + name form the resource's **address**: `aws_s3_bucket.first`. You use the address to refer to the resource elsewhere, e.g. `aws_s3_bucket.first.arn`.

### Arguments vs attributes

- **Arguments** are what *you set* (`bucket_prefix`).
- **Attributes** are what you can *read* after creation (`arn`, `id`, `bucket`). Many are only known after AWS creates the object — the plan shows them as `(known after apply)`.

Every resource type's arguments and attributes are listed in its documentation page, e.g. [aws_s3_bucket](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket). **Reading resource docs is a core Terraform skill.**

---

## 3. Configuration files

### Terraform reads every `.tf` file in the directory

A directory of `.tf` files is called a **module**; the directory you run `terraform` in is the **root module**. Terraform loads *all* `.tf` files in it and treats them as one configuration. File names have **no special meaning to Terraform** — splitting code across files is purely for humans.

The conventional layout, used throughout this course:

| File | Conventionally contains |
| --- | --- |
| `versions.tf` | `terraform { required_version, required_providers }` |
| `providers.tf` | `provider` blocks |
| `main.tf` | The main resources (large configs split this by topic: `network.tf`, `iam.tf`, …) |
| `variables.tf` | `variable` blocks — inputs ([Chapter 07](../07-variables-and-outputs/README.md)) |
| `outputs.tf` | `output` blocks — results ([Chapter 07](../07-variables-and-outputs/README.md)) |
| `locals.tf` | `locals` blocks — internal named values ([Chapter 08](../08-data-sources-and-locals/README.md)) |
| `data.tf` | `data` blocks — lookups ([Chapter 08](../08-data-sources-and-locals/README.md)) |
| `backend.tf` | Where state is stored ([Chapter 12](../12-remote-state/README.md)) |
| `terraform.tfvars` | Values for variables, loaded automatically |
| `*.auto.tfvars` | More variable values, also loaded automatically |

Small labs (like the first one below) put everything in `main.tf`. That is equally valid.

### Files Terraform creates

| Path | What it is | Commit to Git? |
| --- | --- | --- |
| `.terraform/` | Downloaded providers and modules. Recreated by `terraform init`. | ❌ Never (large, platform-specific) |
| `.terraform.lock.hcl` | **Dependency lock file**: the exact provider versions and checksums selected by `init` | ✅ Yes, for root modules |
| `terraform.tfstate` | **State**: the mapping between your code and real AWS objects | ❌ Never (may contain secrets; use remote state) |
| `terraform.tfstate.backup` | The previous state, kept by Terraform after each write | ❌ Never |
| `*.tfvars` | Your variable values | ❌ Usually not (may be environment-specific or sensitive) — commit a `terraform.tfvars.example` instead |

### Why commit the lock file?

Without it, `terraform init` on a colleague's laptop (or in CI) might pick a **newer provider version** than the one you tested with. The lock file makes everyone use the same version until someone deliberately runs `terraform init -upgrade` and commits the new lock file. It also stores checksums, so a tampered provider download is rejected.

Reusable child modules (like those in [modules/](../../modules/README.md)) do **not** commit a lock file: the root module that uses them decides provider versions.

This repository's [.gitignore](../../.gitignore) implements these rules.

---

## 4. Lab: your first S3 bucket

**Lab folder:** [examples/beginner/01-first-s3-bucket](../../examples/beginner/01-first-s3-bucket/README.md)

The whole configuration:

```hcl
provider "aws" {
  region = "us-east-1"
}

resource "aws_s3_bucket" "first" {
  bucket_prefix = "tf-learning-first-"

  tags = {
    Name      = "my-first-terraform-bucket"
    ManagedBy = "Terraform"
  }
}

output "bucket_name" {
  description = "The name AWS generated for the bucket."
  value       = aws_s3_bucket.first.bucket
}
```

### Run it

```bash
cd examples/beginner/01-first-s3-bucket
terraform init
terraform plan
terraform apply
```

### What you should observe

1. `terraform init` downloads the AWS provider into `.terraform/` and creates `.terraform.lock.hcl` (or verifies the committed one).
2. `terraform plan` shows `+ resource "aws_s3_bucket" "first"` and `Plan: 1 to add, 0 to change, 0 to destroy.` Many attributes read `(known after apply)`.
3. `terraform apply` shows the same plan, asks for confirmation (type `yes`), creates the bucket and prints the `bucket_name` output.
4. A new file `terraform.tfstate` appears in the directory.

### Verify

```bash
terraform output bucket_name
aws s3api head-bucket --bucket "$(terraform output -raw bucket_name)"   # no output = bucket exists
terraform state list                                                     # aws_s3_bucket.first
```

Now run `terraform plan` again. It reports **No changes** — the real bucket already matches the code. That is idempotency in action.

### Experiment

Add a tag `Owner = "your-name"` inside `tags`, run `terraform plan`, and note the `~` (update in place) symbol. Apply it. Then change `bucket_prefix` and plan again: note `-/+` (**replace**) — bucket names cannot be changed, so Terraform must delete and recreate the bucket. Always read the plan symbols before typing `yes`.

### Cleanup

```bash
terraform destroy
```

Type `yes`. The bucket is deleted and the state file becomes empty (the file itself remains).

---

## Key takeaways

- A **provider** is a plugin for one platform; a **resource** is one object Terraform manages.
- Address = `TYPE.NAME`; reference attributes as `TYPE.NAME.ATTRIBUTE`.
- Terraform loads **all** `.tf` files in a directory; file names are a convention.
- Commit `.tf` files and `.terraform.lock.hcl`; never commit `.terraform/`, state files, or real `tfvars`.

## Official references

- [Terraform language: files and directories](https://developer.hashicorp.com/terraform/language/files)
- [Resource blocks](https://developer.hashicorp.com/terraform/language/resources/syntax)
- [Provider requirements](https://developer.hashicorp.com/terraform/language/providers/requirements)
- [Dependency lock file](https://developer.hashicorp.com/terraform/language/files/dependency-lock)
- [aws_s3_bucket resource](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket)

---

[← 02 · Installation and Setup](../02-installation-and-setup/README.md) | [🏠 Home](../../README.md) | [📚 Learning Path](../00-learning-roadmap/README.md) | [04 · HCL Fundamentals →](../04-hcl-fundamentals/README.md)
