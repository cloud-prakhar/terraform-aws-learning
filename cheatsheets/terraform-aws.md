[⬆ Terraform on AWS](../README.md) | [🏠 Home](../README.md) | [📚 Learning Path](../docs/00-learning-roadmap/README.md)

# Cheatsheet · AWS Provider

Lesson: [Ch. 06](../docs/06-aws-provider/README.md) · Services: [aws-services/](../aws-services/README.md)

## Requirements and provider

```hcl
terraform {
  required_version = ">= 1.11.0"
  required_providers {
    aws = { source = "hashicorp/aws", version = "~> 6.0" }
  }
}

provider "aws" {
  region              = var.aws_region
  profile             = var.aws_profile          # null → default chain
  allowed_account_ids = ["111122223333"]         # safety net
  default_tags {
    tags = { Project = "x", ManagedBy = "Terraform" }
  }
  # assume_role { role_arn = "arn:aws:iam::111122223333:role/deployer" }
}
```

## Authentication (never in code)

```bash
aws configure sso --profile learning && aws sso login --profile learning
export AWS_PROFILE=learning
aws sts get-caller-identity
```

CI: GitHub OIDC → `aws-actions/configure-aws-credentials` with `role-to-assume`.

## Handy data sources

```hcl
data "aws_caller_identity" "current" {}        # .account_id
data "aws_region" "current" {}                 # .region
data "aws_availability_zones" "available" { state = "available" }
data "aws_ami" "al2023" {
  most_recent = true
  owners      = ["amazon"]
  filter {
    name   = "name"
    values = ["al2023-ami-2023.*-x86_64"]
  }
}
data "aws_vpc" "default" { default = true }
# data "aws_iam_policy_document" builds IAM JSON from statement blocks
```

## Patterns by service

| Service | Remember |
| --- | --- |
| S3 | One resource per setting (versioning, SSE, PAB, ownership, lifecycle, policy); `bucket_prefix`; never public |
| IAM | Trust policy (who) ≠ permissions policy (what); instance profile for EC2; `aws_iam_policy_document` |
| VPC | Public = route to IGW; NAT is hourly; `cidrsubnet()`; `aws_default_security_group` to lock the default |
| Security groups | `aws_vpc_security_group_ingress_rule`/`_egress_rule`; Terraform removes default egress; reference SGs |
| EC2 | Look up AMIs; `http_tokens = "required"`; encrypted root; `vpc_security_group_ids`; SSM over SSH |
| KMS | Key policy with account-root statement; rotation; aliases; S3 Bucket Keys |
| Secrets Manager | Keep values out of state: managed passwords, ephemeral + `*_wo`; pass ARNs |
| Lambda | Execution role ≠ `aws_lambda_permission`; create `/aws/lambda/<name>` log group; `source_code_hash` |
| SQS / SNS | DLQ + redrive; visibility ≥ 6× Lambda timeout; queue policy for SNS with `aws:SourceArn` |
| ALB / ASG | LB → listener → target group; `health_check_type = "ELB"`; `ignore_changes = [desired_capacity]` |
| RDS | Private; `manage_master_user_password`; `deletion_protection`; final snapshot in prod |

## Cost flags 💰

NAT gateway · load balancers · RDS · public IPv4 addresses · KMS keys (monthly) · Secrets Manager secrets · Route 53 hosted zones · CloudWatch logs without retention

---

[⬆ Terraform on AWS](../README.md) | [🏠 Home](../README.md) | [📚 Learning Path](../docs/00-learning-roadmap/README.md)
