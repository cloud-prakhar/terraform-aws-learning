[⬆ CloudWatch](../README.md) | [🏠 Home](../../../README.md) | [📚 Learning Path](../../../docs/00-learning-roadmap/README.md)

# Lab · Logs, metric filter and alarm

🟢 Beginner · [CloudWatch track](../README.md) · 💰 Small: one alarm (monthly charge) and a few KB of logs

## What will be created

| Resource | Purpose |
| --- | --- |
| `aws_cloudwatch_log_group.app` | `/tf-learning/app`, 14-day retention |
| `aws_cloudwatch_log_metric_filter.errors` | Each log event containing `ERROR` adds 1 to `TfLearning/App AppErrors` |
| `aws_sns_topic.alerts` | Notification target |
| `aws_sns_topic_subscription.email[0]` | Only if you set `alert_email` |
| `aws_cloudwatch_metric_alarm.errors` | ALARM when more than 5 errors in 5 minutes |

## Commands

```bash
terraform init
terraform apply                                   # or: -var alert_email=you@example.com
```

If you set an email, confirm the subscription from the email AWS sends.

## Verification: make the alarm fire

```bash
LG=$(terraform output -raw log_group_name)
aws logs create-log-stream --log-group-name "$LG" --log-stream-name test
NOW=$(($(date +%s) * 1000))
EVENTS=$(for i in 1 2 3 4 5 6 7; do printf '{"timestamp":%s,"message":"ERROR payment failed %s"},' "$NOW" "$i"; done)
aws logs put-log-events --log-group-name "$LG" --log-stream-name test --log-events "[${EVENTS%,}]"

# wait ~5 minutes, then:
aws cloudwatch describe-alarms --alarm-names "$(terraform output -raw alarm_name)" \
  --query "MetricAlarms[0].StateValue"            # "ALARM"
```

## Cleanup

```bash
terraform destroy
```

---

[⬆ CloudWatch](../README.md) | [🏠 Home](../../../README.md) | [📚 Learning Path](../../../docs/00-learning-roadmap/README.md)
