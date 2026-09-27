[⬆ Reusable modules](../README.md) | [🏠 Home](../../README.md) | [📚 Learning Path](../../docs/00-learning-roadmap/README.md)

# Module · iam

An IAM role that AWS services (EC2, Lambda, …) can assume, with managed and inline permission policies and an optional EC2 instance profile. Concepts: [IAM track](../../aws-services/iam/README.md).

## What it creates

| Resource | Purpose |
| --- | --- |
| `aws_iam_role` | Trust policy built from `trusted_services` |
| `aws_iam_role_policy_attachment` (for_each) | One per ARN in `managed_policy_arns` |
| `aws_iam_role_policy` (for_each) | One per entry in `inline_policies` (name → JSON) |
| `aws_iam_instance_profile` | When `create_instance_profile = true` |

## Usage

```hcl
module "app_role" {
  source = "../../modules/iam"

  name                    = "myapp-dev-app"
  trusted_services        = ["ec2.amazonaws.com"]
  managed_policy_arns     = ["arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"]
  inline_policies         = { "read-artifacts" = data.aws_iam_policy_document.read.json }
  create_instance_profile = true
}
```

- Example: [examples/basic](examples/basic/main.tf)
- Tests: [tests/iam.tftest.hcl](tests/iam.tftest.hcl)

## Design notes: why `inline_policies` is a map

An earlier version had `inline_policy_json` (a string or `null`) and `count = var.inline_policy_json == null ? 0 : 1`. It failed when the JSON referenced a resource created in the same apply (e.g. a bucket ARN): the JSON is unknown at plan time, so `count` is unknown, and Terraform stops with *"Invalid count argument"*. A map with **static keys** and `for_each` works, because keys are known at plan time even when values are not. See [Chapter 22](../../docs/22-troubleshooting/README.md#invalid-count-or-for_each-argument).

<!-- BEGIN_TF_DOCS -->
### Requirements

| Name | Version |
| ---- | ------- |
| terraform | >= 1.11.0 |
| aws | >= 6.0 |

### Providers

| Name | Version |
| ---- | ------- |
| aws | >= 6.0 |

### Resources

| Name | Type |
| ---- | ---- |
| [aws_iam_instance_profile.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_instance_profile) | resource |
| [aws_iam_role.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy.inline](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy) | resource |
| [aws_iam_role_policy_attachment.managed](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_policy_document.trust](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |

### Inputs

| Name | Description | Type | Default | Required |
| ---- | ----------- | ---- | ------- | :------: |
| name | Name of the IAM role. | `string` | n/a | yes |
| trusted\_services | AWS service principals allowed to assume the role, e.g. ["ec2.amazonaws.com"]. This becomes the TRUST policy. | `list(string)` | n/a | yes |
| create\_instance\_profile | Also create an instance profile so EC2 instances can use the role. | `bool` | `false` | no |
| description | Human-readable description of what the role is for. | `string` | `"Managed by Terraform"` | no |
| inline\_policies | Inline permissions policies: map of policy name => policy JSON (e.g. from aws\_iam\_policy\_document). Keys must be known at plan time; values may be computed. | `map(string)` | `{}` | no |
| managed\_policy\_arns | ARNs of managed policies to attach (PERMISSIONS). | `list(string)` | `[]` | no |
| tags | Tags to add to the role and instance profile. | `map(string)` | `{}` | no |

### Outputs

| Name | Description |
| ---- | ----------- |
| instance\_profile\_name | Instance profile name, or null when not created. |
| role\_arn | ARN of the IAM role. |
| role\_name | Name of the IAM role. |
<!-- END_TF_DOCS -->

---

[⬆ Reusable modules](../README.md) | [🏠 Home](../../README.md) | [📚 Learning Path](../../docs/00-learning-roadmap/README.md)
