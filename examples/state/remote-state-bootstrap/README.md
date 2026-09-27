[⬆ Examples](../../README.md) | [🏠 Home](../../../README.md) | [📚 Learning Path](../../../docs/00-learning-roadmap/README.md)

# Lab · Bootstrap a remote state bucket

🟡 Intermediate · Used in [Chapter 12](../../../docs/12-remote-state/README.md) · 💰 Free (a few KB of versioned objects)

## What will be created

| Resource | Protection it adds |
| --- | --- |
| `aws_s3_bucket.state` | `lifecycle { prevent_destroy = true }` |
| `aws_s3_bucket_ownership_controls.state` | ACLs disabled |
| `aws_s3_bucket_public_access_block.state` | No public access, ever |
| `aws_s3_bucket_versioning.state` | Every state version kept |
| `aws_s3_bucket_server_side_encryption_configuration.state` | SSE-S3 at rest |
| `aws_s3_bucket_lifecycle_configuration.state` | Old versions expire after `noncurrent_version_retention_days` (90) |
| `aws_s3_bucket_policy.state` | HTTPS only |

This configuration itself uses **local** state, because the bucket can't hold the state of its own creation. Keep `terraform.tfstate` from this folder safe until you tear the lab down.

## Commands

```bash
terraform init
terraform apply
terraform output -raw backend_hcl      # copy this into the next lab's backend.hcl
```

## Verification

```bash
BUCKET=$(terraform output -raw state_bucket)
aws s3api get-bucket-versioning --bucket "$BUCKET"
aws s3api get-bucket-policy --bucket "$BUCKET" --query Policy --output text | jq .
terraform plan -destroy                # fails: prevent_destroy protects the bucket
```

## Cleanup (only after the backend lab is destroyed)

1. In [main.tf](main.tf) set `prevent_destroy = false` and run `terraform apply`.
2. Empty the bucket, including all versions (the bucket is versioned, so `aws s3 rm --recursive` is not enough):

```bash
BUCKET=$(terraform output -raw state_bucket)
aws s3api delete-objects --bucket "$BUCKET" --delete "$(aws s3api list-object-versions --bucket "$BUCKET" \
  --query '{Objects: [Versions, DeleteMarkers][][].{Key: Key, VersionId: VersionId}}' --output json)"
```

3. `terraform destroy`

(If `delete-objects` reports an empty object list, the bucket was already empty.)

---

[⬆ Examples](../../README.md) | [🏠 Home](../../../README.md) | [📚 Learning Path](../../../docs/00-learning-roadmap/README.md)
