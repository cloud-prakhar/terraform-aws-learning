[⬆ Examples](../../README.md) | [🏠 Home](../../../README.md) | [📚 Learning Path](../../../docs/00-learning-roadmap/README.md)

# Lab · Import an existing bucket

🟡 Intermediate · Used in [Chapter 15](../../../docs/15-import-and-existing-resources/README.md) · 💰 Free (empty bucket)

## Scenario

Someone created a bucket in the console. You want Terraform to manage it **without** deleting and recreating it.

## Steps

**1 · Create the "legacy" bucket outside Terraform**

```bash
export LEGACY_BUCKET="tf-learning-legacy-$(date +%s)"
aws s3api create-bucket --bucket "$LEGACY_BUCKET" --region us-east-1
aws s3api put-bucket-tagging --bucket "$LEGACY_BUCKET" --tagging 'TagSet=[{Key=Owner,Value=console-user}]'
```

**2 · Plan the import**

[import.tf](import.tf) contains an `import` block; [main.tf](main.tf) contains the matching `resource` block.

```bash
terraform init
terraform plan -var existing_bucket_name="$LEGACY_BUCKET"
```

The plan shows `1 to import` — and **also** an update, because the code doesn't declare the `Owner` tag, but the real bucket has it (and the provider's `default_tags` add three more). This is the key lesson: **import fills state; your code must still describe the resource.**

**3 · Make the code match reality**

Add to the resource in `main.tf`:

```hcl
  tags = {
    Owner = "console-user"
  }
```

Plan again: `1 to import, 1 to change` (only the `default_tags` being added — accept that, or remove `default_tags` for this lab).

**4 · Apply**

```bash
terraform apply -var existing_bucket_name="$LEGACY_BUCKET"
terraform state list          # aws_s3_bucket.legacy
```

The `import` block can now be deleted (keeping it is harmless: already-imported resources are skipped).

**5 · (Optional) Let Terraform draft the configuration**

Start again with a new bucket, delete the `resource` block from `main.tf`, keep the `import` block, and run:

```bash
terraform plan -var existing_bucket_name="$LEGACY_BUCKET" -generate-config-out=generated.tf
```

Terraform writes a `generated.tf` with every attribute it found. The feature is marked **experimental**; the output is a starting point to review and clean up, not finished code.

## Cleanup

```bash
terraform destroy -var existing_bucket_name="$LEGACY_BUCKET"
```

---

[⬆ Examples](../../README.md) | [🏠 Home](../../../README.md) | [📚 Learning Path](../../../docs/00-learning-roadmap/README.md)
