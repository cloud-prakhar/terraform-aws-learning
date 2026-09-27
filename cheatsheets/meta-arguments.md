[⬆ Terraform on AWS](../README.md) | [🏠 Home](../README.md) | [📚 Learning Path](../docs/00-learning-roadmap/README.md)

# Cheatsheet · Meta-Arguments

Lesson: [Ch. 09](../docs/09-meta-arguments/README.md)

## count

```hcl
resource "aws_instance" "w" {
  count = 3                                  # aws_instance.w[0..2]
  tags  = { Name = "w-${count.index}" }
}
resource "aws_eip" "nat" {
  count = var.enable_nat ? 1 : 0             # optional resource
}
# one(aws_eip.nat[*].id) → id or null
```

## for_each

```hcl
resource "aws_s3_bucket" "b" {
  for_each      = { logs = "l-", data = "d-" }   # map
  bucket_prefix = each.value                     # each.key = "logs"
}
resource "aws_sqs_queue" "q" {
  for_each = toset(["a", "b"])                   # set of strings
  name     = each.value
}
resource "aws_s3_bucket_versioning" "b" {
  for_each = aws_s3_bucket.b                     # chain: same keys
  bucket   = each.value.id
  versioning_configuration { status = "Enabled" }
}
```

Keys must be known at plan time. Values may be unknown.

## count vs for_each

| Use `count` | Use `for_each` |
| --- | --- |
| N identical copies | Copies with names / different settings |
| Optional resource (0 or 1) | Anything built from a list you might edit |

Removing a middle list element with `count` shifts indexes → unrelated replacements.

## depends_on

```hcl
depends_on = [aws_iam_role_policy.read_config]   # only for hidden dependencies
```

## provider / providers

```hcl
provider "aws" {
  alias  = "west"
  region = "us-west-2"
}
resource "aws_s3_bucket" "b" { provider = aws.west }
module "m" {
  source    = "./m"
  providers = { aws = aws.west }
}
```

## lifecycle

```hcl
lifecycle {
  create_before_destroy = true                   # new before old (use name_prefix)
  prevent_destroy       = true                   # plans that destroy fail
  ignore_changes        = [ami, tags["Patch"]]   # managed elsewhere
  replace_triggered_by  = [terraform_data.version]
  precondition {
    condition     = var.env != ""
    error_message = "env must be set."
  }
  postcondition {
    condition     = self.private_ip != ""
    error_message = "No private IP assigned."
  }
}
```

Lifecycle values must be literals (no variables).

## Refactoring blocks

```hcl
moved {
  from = aws_sqs_queue.a
  to   = aws_sqs_queue.b
}

removed {
  from = aws_s3_bucket.old
  lifecycle {
    destroy = false
  }
}

import {
  to = aws_s3_bucket.legacy
  id = "bucket-name"
}
```

---

[⬆ Terraform on AWS](../README.md) | [🏠 Home](../README.md) | [📚 Learning Path](../docs/00-learning-roadmap/README.md)
