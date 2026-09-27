[⬆ KMS](../README.md) | [🏠 Home](../../../README.md) | [📚 Learning Path](../../../docs/00-learning-roadmap/README.md)

# Lab · Customer managed KMS key

🟡 Intermediate · [KMS track](../README.md) · 💰 One customer managed key: **monthly charge while it exists** (prorated), plus requests. After `destroy`, the key is *scheduled* for deletion (7 days) and no longer usable.

## What will be created

| Resource | Purpose |
| --- | --- |
| `aws_kms_key.data` | Key with an explicit key policy, yearly rotation, 7-day deletion window |
| `aws_kms_alias.data` | `alias/tf-learning-data` |
| `aws_s3_bucket.encrypted` + SSE configuration | Default encryption SSE-KMS with S3 Bucket Keys |
| `aws_s3_bucket_public_access_block.encrypted` | Keep the bucket private |

## Commands

```bash
terraform init
terraform apply
```

## Verification

```bash
BUCKET=$(terraform output -raw bucket_name)
echo "secret report" | aws s3 cp - "s3://$BUCKET/report.txt"
aws s3api head-object --bucket "$BUCKET" --key report.txt \
  --query "[ServerSideEncryption,SSEKMSKeyId,BucketKeyEnabled]"
aws kms describe-key --key-id alias/tf-learning-data --query "KeyMetadata.[KeyState,KeyManager]"
aws kms get-key-rotation-status --key-id alias/tf-learning-data
```

Expect `aws:kms`, your key's ARN, `true`; `Enabled`, `CUSTOMER`; rotation enabled.

## Cleanup

Note the key ARN first, then destroy:

```bash
KEY_ARN=$(terraform output -raw key_arn)
terraform destroy
aws kms describe-key --key-id "$KEY_ARN" --query "KeyMetadata.[KeyState,DeletionDate]"
```

After destroy, the key is in state `PendingDeletion` for 7 days; you can cancel with `aws kms cancel-key-deletion` if you destroyed it by mistake. The alias name becomes free immediately.

---

[⬆ KMS](../README.md) | [🏠 Home](../../../README.md) | [📚 Learning Path](../../../docs/00-learning-roadmap/README.md)
