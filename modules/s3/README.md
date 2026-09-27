[⬆ Reusable modules](../README.md) | [🏠 Home](../../README.md) | [📚 Learning Path](../../docs/00-learning-roadmap/README.md)

# Module · s3

A private S3 bucket with the settings every bucket should have. Explained in [Chapter 13](../../docs/13-terraform-modules/README.md); the underlying resources are taught in the [S3 track](../../aws-services/s3/README.md).

## What it creates

| Resource | Setting |
| --- | --- |
| `aws_s3_bucket` | Name from `bucket_prefix` + unique suffix |
| `aws_s3_bucket_ownership_controls` | `BucketOwnerEnforced` (ACLs disabled) |
| `aws_s3_bucket_public_access_block` | All four blocks on |
| `aws_s3_bucket_versioning` | Enabled unless `versioning_enabled = false` |
| `aws_s3_bucket_server_side_encryption_configuration` | SSE-S3, or SSE-KMS with Bucket Keys when `kms_key_arn` is set |
| `aws_s3_bucket_lifecycle_configuration` | Abort incomplete uploads after 7 days; expire old versions |
| `aws_s3_bucket_policy` | Deny non-HTTPS requests |

## Usage

```hcl
module "artifacts" {
  source = "../../modules/s3"

  bucket_prefix = "myapp-artifacts-"
  kms_key_arn   = aws_kms_key.data.arn   # optional
  tags          = { Team = "platform" }
}
```

- Example: [examples/basic](examples/basic/main.tf)
- Tests: [tests/s3.tftest.hcl](tests/s3.tftest.hcl) — secure defaults, KMS switch, input validation

## Design notes

- `force_destroy` defaults to `false`: deleting a non-empty bucket should be a deliberate decision.
- `lifecycle { prevent_destroy }` can't be set through a variable, so callers who need it (e.g. state buckets) should use their own resources or a wrapper module.

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
| [aws_s3_bucket.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket) | resource |
| [aws_s3_bucket_lifecycle_configuration.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_lifecycle_configuration) | resource |
| [aws_s3_bucket_ownership_controls.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_ownership_controls) | resource |
| [aws_s3_bucket_policy.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_policy) | resource |
| [aws_s3_bucket_public_access_block.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_public_access_block) | resource |
| [aws_s3_bucket_server_side_encryption_configuration.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_server_side_encryption_configuration) | resource |
| [aws_s3_bucket_versioning.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_versioning) | resource |
| [aws_iam_policy_document.tls_only](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |

### Inputs

| Name | Description | Type | Default | Required |
| ---- | ----------- | ---- | ------- | :------: |
| bucket\_prefix | Prefix for the bucket name. AWS appends a unique suffix so names never collide. | `string` | n/a | yes |
| force\_destroy | Allow Terraform to delete the bucket even when it contains objects. Keep false for real data. | `bool` | `false` | no |
| kms\_key\_arn | ARN of a customer managed KMS key for SSE-KMS. When null, SSE-S3 (AES256) is used. | `string` | `null` | no |
| noncurrent\_version\_expiration\_days | Delete previous object versions after this many days. Only applies when versioning is enabled. | `number` | `90` | no |
| tags | Tags to add to the bucket. | `map(string)` | `{}` | no |
| versioning\_enabled | Keep previous versions of every object so deletes and overwrites can be undone. | `bool` | `true` | no |

### Outputs

| Name | Description |
| ---- | ----------- |
| bucket\_arn | ARN of the bucket, for IAM policies. |
| bucket\_id | Name of the bucket (for S3 the ID and the name are the same). |
| bucket\_regional\_domain\_name | Regional domain name, e.g. for a CloudFront origin. |
<!-- END_TF_DOCS -->

---

[⬆ Reusable modules](../README.md) | [🏠 Home](../../README.md) | [📚 Learning Path](../../docs/00-learning-roadmap/README.md)
