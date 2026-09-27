[⬆ Meta-argument labs](../README.md) | [🏠 Home](../../../README.md) | [📚 Learning Path](../../../docs/00-learning-roadmap/README.md)

# Lab · count vs for_each

🟡 Intermediate · [Chapter 09](../../../docs/09-meta-arguments/README.md#3-count-vs-for_each) · 💰 Free (idle SQS queues have no hourly cost)

The same three queues are created twice: once with `count`, once with `for_each`. Then you remove the middle element and compare the plans.

## What will be created

| count | for_each |
| --- | --- |
| `aws_sqs_queue.by_count[0]` → `count-orders` | `aws_sqs_queue.by_key["orders"]` → `foreach-orders` |
| `aws_sqs_queue.by_count[1]` → `count-payments` | `aws_sqs_queue.by_key["payments"]` → `foreach-payments` |
| `aws_sqs_queue.by_count[2]` → `count-emails` | `aws_sqs_queue.by_key["emails"]` → `foreach-emails` |

## Steps

```bash
terraform init
terraform apply

# Remove "payments" from the middle of the list:
terraform plan -var 'queue_names=["orders","emails"]'
```

## What to look for in the plan

- **count:** `by_count[1]` must be **replaced** (its name changes from `count-payments` to `count-emails`, and a queue name cannot be changed), and `by_count[2]` is **destroyed**. The `emails` queue loses its identity — and would lose its messages.
- **for_each:** only `by_key["payments"]` is **destroyed**. `orders` and `emails` are untouched.
- The plan summary shows a total of 1 to add and 3 to destroy: 2 destroys + 1 replacement from `count`, 1 destroy from `for_each`.

## Cleanup

```bash
terraform destroy
```

---

[⬆ Meta-argument labs](../README.md) | [🏠 Home](../../../README.md) | [📚 Learning Path](../../../docs/00-learning-roadmap/README.md)
