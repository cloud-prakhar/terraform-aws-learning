[⬆ S3](../README.md) | [🏠 Home](../../../README.md) | [📚 Learning Path](../../../docs/00-learning-roadmap/README.md)

# Lab · Secure S3 bucket

🟢 Beginner · [S3 track](../README.md) · 💰 Free while (nearly) empty — one tiny object

## What will be created

| Resource | Setting |
| --- | --- |
| `aws_s3_bucket.this` | Name `tf-learning-s3-lab-<suffix>`, `force_destroy = true` (lab only) |
| `aws_s3_bucket_ownership_controls.this` | `BucketOwnerEnforced` (ACLs disabled) |
| `aws_s3_bucket_public_access_block.this` | All four switches on |
| `aws_s3_bucket_versioning.this` | Enabled |
| `aws_s3_bucket_server_side_encryption_configuration.this` | SSE-S3 (AES256) |
| `aws_s3_bucket_lifecycle_configuration.this` | `logs/` → STANDARD_IA after 30 days, deleted after `log_retention_days`; old versions deleted after 30 days; incomplete uploads aborted after 7 days |
| `aws_s3_bucket_policy.this` | Deny any request not using HTTPS |
| `aws_s3_object.readme` | `docs/readme.txt` |

## Commands

```bash
terraform init
terraform apply
terraform output
```

## Verification

```bash
BUCKET=$(terraform output -raw bucket_name)
aws s3api get-bucket-versioning --bucket "$BUCKET"                 # "Status": "Enabled"
aws s3api get-public-access-block --bucket "$BUCKET"
aws s3api get-bucket-encryption --bucket "$BUCKET"
aws s3api get-bucket-lifecycle-configuration --bucket "$BUCKET"
aws s3 cp "s3://$BUCKET/docs/readme.txt" -                          # prints the object
```

**See versioning work:**

```bash
echo "v2" | aws s3 cp - "s3://$BUCKET/docs/readme.txt"
aws s3api list-object-versions --bucket "$BUCKET" --prefix docs/ --query "Versions[].[VersionId,IsLatest]"
```

Two versions are listed: the one Terraform uploaded and your overwrite. The earlier version can still be downloaded with `--version-id`.

## Cleanup

```bash
terraform destroy    # force_destroy removes all object versions first
```

---

[⬆ S3](../README.md) | [🏠 Home](../../../README.md) | [📚 Learning Path](../../../docs/00-learning-roadmap/README.md)
