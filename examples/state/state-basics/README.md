[⬆ Examples](../../README.md) | [🏠 Home](../../../README.md) | [📚 Learning Path](../../../docs/00-learning-roadmap/README.md)

# Lab · State basics

🟡 Intermediate · Used in [Chapter 11](../../../docs/11-terraform-state/README.md) · 💰 Free (idle queue, empty bucket)

## What will be created

| Address | Object |
| --- | --- |
| `aws_sqs_queue.orders` | Queue `tf-learning-state-orders` |
| `aws_s3_bucket.uploads` | Bucket `tf-learning-state-uploads-<suffix>` |

State is **local** here (`terraform.tfstate` in this folder). [Chapter 12](../../../docs/12-remote-state/README.md) moves it to S3.

## Exercises

```bash
terraform init
terraform apply
```

**1 · Inspect state**

```bash
terraform state list
terraform state show aws_sqs_queue.orders
terraform show -json | jq '.values.root_module.resources[] | {address, id: .values.id}'
```

**2 · Rename with a `moved` block**

1. In [main.tf](main.tf), rename `resource "aws_sqs_queue" "orders"` to `"order_events"`.
2. In [outputs.tf](outputs.tf), change `aws_sqs_queue.orders.url` to `aws_sqs_queue.order_events.url`.
3. Uncomment the `moved` block at the bottom of `main.tf`.
4. `terraform plan` → the queue "has moved"; **0 to add, 0 to destroy**.
5. Now comment the `moved` block out again *without* applying, and plan: Terraform wants to destroy `orders` and create `order_events`. That is what `moved` saves you from. Uncomment it and `terraform apply`.

**3 · Detect drift**

```bash
aws sqs set-queue-attributes --queue-url "$(terraform output -raw queue_url)" --attributes VisibilityTimeout=120
terraform plan -refresh-only
terraform apply            # restores 30 seconds
```

**4 · Forget a resource without deleting it**

Replace the `aws_s3_bucket.uploads` block (and its output) with:

```hcl
removed {
  from = aws_s3_bucket.uploads
  lifecycle {
    destroy = false
  }
}
```

`terraform apply` → the bucket disappears from `terraform state list` but still exists in AWS (`aws s3 ls | grep state-uploads`). Delete it manually afterwards: `aws s3 rb s3://<bucket-name>`.

## Cleanup

```bash
terraform destroy
```

---

[⬆ Examples](../../README.md) | [🏠 Home](../../../README.md) | [📚 Learning Path](../../../docs/00-learning-roadmap/README.md)
