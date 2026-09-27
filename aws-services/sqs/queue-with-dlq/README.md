[⬆ SQS](../README.md) | [🏠 Home](../../../README.md) | [📚 Learning Path](../../../docs/00-learning-roadmap/README.md)

# Lab · Queue with a dead-letter queue

🟢 Beginner · [SQS track](../README.md) · 💰 Per request; idle queues cost nothing

## What will be created

| Resource | Settings |
| --- | --- |
| `aws_sqs_queue.orders_dlq` | 14-day retention, SSE-SQS |
| `aws_sqs_queue.orders` | 60 s visibility, 4-day retention, 20 s long polling, SSE-SQS, redrive to DLQ after 3 receives |
| `aws_sqs_queue_redrive_allow_policy.orders_dlq` | Only `orders` may send to the DLQ |

## Commands

```bash
terraform init
terraform apply
```

## Verification: send a message and let it fail three times

```bash
Q=$(terraform output -raw queue_url)
DLQ=$(terraform output -raw dlq_url)

aws sqs send-message --queue-url "$Q" --message-body '{"order": 42}'

# Receive WITHOUT deleting, three times. --visibility-timeout 1 lets the
# message reappear after 1 second instead of 60.
for i in 1 2 3; do
  aws sqs receive-message --queue-url "$Q" --visibility-timeout 1 --wait-time-seconds 5 \
    --attribute-names ApproximateReceiveCount --query "Messages[0].Attributes"
  sleep 2
done

# The 4th receive attempt moves it to the DLQ:
aws sqs receive-message --queue-url "$Q" --wait-time-seconds 5
aws sqs receive-message --queue-url "$DLQ" --wait-time-seconds 5 --query "Messages[0].Body"
```

## Cleanup

```bash
terraform destroy
```

---

[⬆ SQS](../README.md) | [🏠 Home](../../../README.md) | [📚 Learning Path](../../../docs/00-learning-roadmap/README.md)
