[⬆ SNS](../README.md) | [🏠 Home](../../../README.md) | [📚 Learning Path](../../../docs/00-learning-roadmap/README.md)

# Lab · SNS fan-out to SQS

🟡 Intermediate · [SNS track](../README.md) · 💰 Per request; idle resources cost nothing

## What will be created

| Resource | Purpose |
| --- | --- |
| `aws_sns_topic.orders` | Topic, encrypted with the AWS managed key `alias/aws/sns` |
| `aws_sqs_queue.consumer["billing"]`, `["shipping"]` | One queue per consumer (`for_each`) |
| `aws_sqs_queue_policy.allow_topic[...]` | Each queue accepts `SendMessage` only from this topic |
| `aws_sns_topic_subscription.consumer[...]` | Raw delivery; shipping has a filter policy `{"status": ["paid"]}` |

## Commands

```bash
terraform init
terraform apply
```

## Verification

```bash
TOPIC=$(terraform output -raw topic_arn)
aws sns publish --topic-arn "$TOPIC" --message '{"order": 1, "status": "paid"}'
aws sns publish --topic-arn "$TOPIC" --message '{"order": 2, "status": "cancelled"}'

BILLING=$(terraform output -json queue_urls | jq -r .billing)
SHIPPING=$(terraform output -json queue_urls | jq -r .shipping)
aws sqs receive-message --queue-url "$BILLING"  --max-number-of-messages 10 --wait-time-seconds 5 --query "Messages[].Body"
aws sqs receive-message --queue-url "$SHIPPING" --max-number-of-messages 10 --wait-time-seconds 5 --query "Messages[].Body"
```

Billing receives both orders. Shipping receives nothing — the filter policy checks **message attributes** by default, and these messages have none. Now publish with an attribute:

```bash
aws sns publish --topic-arn "$TOPIC" --message '{"order": 3}' \
  --message-attributes '{"status":{"DataType":"String","StringValue":"paid"}}'
aws sqs receive-message --queue-url "$SHIPPING" --wait-time-seconds 5 --query "Messages[].Body"
```

Shipping receives order 3. (To filter on the message *body* instead, set `filter_policy_scope = "MessageBody"` on the subscription.)

## Cleanup

```bash
terraform destroy
```

---

[⬆ SNS](../README.md) | [🏠 Home](../../../README.md) | [📚 Learning Path](../../../docs/00-learning-roadmap/README.md)
