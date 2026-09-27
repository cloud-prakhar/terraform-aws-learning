[⬆ Route 53](../README.md) | [🏠 Home](../../../README.md) | [📚 Learning Path](../../../docs/00-learning-roadmap/README.md)

# Lab · Private hosted zone

🟢 Beginner · [Route 53 track](../README.md) · 💰 One hosted zone: **monthly charge** (a zone deleted within 12 hours of creation is not charged — see the pricing page)

## What will be created

| Resource | Purpose |
| --- | --- |
| `aws_route53_zone.internal` | Private zone `tf-learning.internal`, associated with the default VPC |
| `aws_route53_record.db` | `db.tf-learning.internal` A `172.31.10.10` |
| `aws_route53_record.database_alias` | `database.tf-learning.internal` CNAME → `db.tf-learning.internal` |

## Commands

```bash
terraform init
terraform apply
terraform output
```

## Verification

```bash
aws route53 list-resource-record-sets --hosted-zone-id "$(terraform output -raw zone_id)" \
  --query "ResourceRecordSets[].[Name,Type,ResourceRecords[0].Value]" --output table
```

The names resolve **only from inside the VPC**. From an instance in the default VPC (e.g. [EC2 lab 01](../../ec2/01-instance-with-ssm/README.md) via SSM), run `dig +short database.tf-learning.internal` (on Amazon Linux: `sudo dnf install -y bind-utils` first). From your laptop, the same query returns nothing — that is the point of a private zone.

## Cleanup

```bash
terraform destroy
```

---

[⬆ Route 53](../README.md) | [🏠 Home](../../../README.md) | [📚 Learning Path](../../../docs/00-learning-roadmap/README.md)
