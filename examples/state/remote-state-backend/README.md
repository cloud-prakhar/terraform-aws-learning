[⬆ Examples](../../README.md) | [🏠 Home](../../../README.md) | [📚 Learning Path](../../../docs/00-learning-roadmap/README.md)

# Lab · Using the S3 backend

🟡 Intermediate · Used in [Chapter 12](../../../docs/12-remote-state/README.md) · 💰 Free (one idle queue + state objects)

## Prerequisites

The bucket from [remote-state-bootstrap](../remote-state-bootstrap/README.md).

## What will be created

One SQS queue, `tf-learning-remote-state-jobs` — but its **state** lives in S3 under the key `examples/remote-state-backend/terraform.tfstate`.

## Files

| File | Purpose |
| --- | --- |
| [backend.tf](backend.tf) | `backend "s3"` with only the `key` (partial configuration) |
| [backend.hcl.example](backend.hcl.example) | Template for `backend.hcl` (git-ignored): bucket, region, `encrypt`, `use_lockfile` |

## Steps

**1 · Configure and initialise**

```bash
cp backend.hcl.example backend.hcl
# paste the bucket name from the bootstrap lab's `terraform output -raw backend_hcl`
terraform init -backend-config=backend.hcl
terraform apply
ls terraform.tfstate 2>/dev/null || echo "no local state file - it is in S3"
aws s3 ls "s3://<bucket>/examples/remote-state-backend/"
```

**2 · See the lock**

In terminal A:

```bash
terraform apply        # leave it waiting at the "Enter a value:" prompt
```

In terminal B (same folder):

```bash
aws s3 ls "s3://<bucket>/examples/remote-state-backend/"   # terraform.tfstate.tflock exists
terraform plan                                              # Error acquiring the state lock
```

Answer `no` in terminal A. The `.tflock` object disappears.

**3 · Version history**

Change `visibility_timeout_seconds` on the queue a couple of times with `terraform apply`, then:

```bash
aws s3api list-object-versions --bucket <bucket> \
  --prefix examples/remote-state-backend/terraform.tfstate \
  --query "Versions[].[VersionId,LastModified]" --output table
```

**4 · Migration back and forth (optional)**

```bash
# S3 → local: comment out the backend block in backend.tf, then
terraform init -migrate-state          # answer yes: state copied to ./terraform.tfstate
# local → S3: restore the backend block, then
terraform init -migrate-state -backend-config=backend.hcl
rm -f terraform.tfstate terraform.tfstate.backup   # only after verifying `terraform state list`
```

## Cleanup

```bash
terraform destroy
```

Then clean up the bootstrap lab if you are finished with remote state.

---

[⬆ Examples](../../README.md) | [🏠 Home](../../../README.md) | [📚 Learning Path](../../../docs/00-learning-roadmap/README.md)
