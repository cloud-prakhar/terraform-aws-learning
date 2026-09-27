[← 10 · Expressions and Functions](../docs/10-expressions-and-functions/README.md) | [🏠 Home](../README.md) | [📚 Learning Path](../docs/00-learning-roadmap/README.md) | [S3 →](s3/README.md)

# AWS Service Tracks

🟢🟡 Stage 3 of the [learning path](../docs/00-learning-roadmap/README.md) · Prerequisite: Chapters 01–10

Each track explains **one AWS service** in plain language (what it is, why it exists, how it works) and then shows how it is modelled in Terraform, with a lab you can run. Follow them in this order — later tracks reuse earlier ones.

```mermaid
flowchart LR
    classDef storage fill:#3B82F6,color:#fff,stroke:#1D4ED8,stroke-width:2px
    classDef security fill:#10B981,color:#fff,stroke:#047857,stroke-width:2px
    classDef network fill:#8B5CF6,color:#fff,stroke:#6D28D9,stroke-width:2px
    classDef compute fill:#FF9900,color:#000,stroke:#C77800,stroke-width:2px
    classDef integ fill:#EC4899,color:#fff,stroke:#BE185D,stroke-width:2px

    S3["S3"]:::storage --> IAM["IAM"]:::security --> VPC["VPC"]:::network --> SG["Security groups"]:::network --> EC2["EC2"]:::compute --> EBS["EBS"]:::storage
    EBS --> KMS["KMS"]:::security --> SM["Secrets Manager"]:::security --> CW["CloudWatch"]:::integ --> LAM["Lambda"]:::compute
    LAM --> SQS["SQS"]:::integ --> SNS["SNS"]:::integ --> ELB["Load balancing"]:::network --> ASG["Auto Scaling"]:::compute --> R53["Route 53"]:::network --> RDS["RDS"]:::storage
```

| # | Track | Lab(s) | 💰 Lab cost | Level |
| --- | --- | --- | --- | --- |
| 1 | [S3](s3/README.md) | [secure-bucket](s3/secure-bucket/README.md) | Free when empty | 🟢 |
| 2 | [IAM](iam/README.md) | [ec2-role](iam/ec2-role/README.md) | Free | 🟢 |
| 3 | [VPC](vpc/README.md) | [01](vpc/01-vpc-and-subnets/README.md) · [02](vpc/02-internet-access/README.md) · [03](vpc/03-private-subnets-nat/README.md) | 01–02 free; **03 hourly (NAT)** | 🟢🟡 |
| 4 | [Security groups](security-groups/README.md) | [tiered-security-groups](security-groups/tiered-security-groups/README.md) | Free | 🟢 |
| 5 | [EC2](ec2/README.md) | [01](ec2/01-instance-with-ssm/README.md) · [02](ec2/02-multiple-instances-with-ebs/README.md) | Hourly (instances) | 🟢🟡 |
| 6 | [EBS](ebs/README.md) | uses EC2 lab 02 | Per GB-month | 🟢 |
| 7 | [KMS](kms/README.md) | [customer-managed-key](kms/customer-managed-key/README.md) | Monthly per key | 🟡 |
| 8 | [Secrets Manager](secrets-manager/README.md) | [secret-without-state](secrets-manager/secret-without-state/README.md) | Monthly per secret | 🟡 |
| 9 | [CloudWatch](cloudwatch/README.md) | [logs-and-alarms](cloudwatch/logs-and-alarms/README.md) | Small | 🟢 |
| 10 | [Lambda](lambda/README.md) | [scheduled-function](lambda/scheduled-function/README.md) | Per use | 🟡 |
| 11 | [SQS](sqs/README.md) | [queue-with-dlq](sqs/queue-with-dlq/README.md) | Per use | 🟢 |
| 12 | [SNS](sns/README.md) | [fan-out](sns/fan-out/README.md) | Per use | 🟡 |
| 13 | [Load balancing](load-balancer/README.md) | [Project 08](../projects/08-highly-available-web/README.md) | **Hourly** | 🟡 |
| 14 | [Auto Scaling](autoscaling/README.md) | [Project 08](../projects/08-highly-available-web/README.md) | Hourly (instances) | 🟡 |
| 15 | [Route 53](route53/README.md) | [private-hosted-zone](route53/private-hosted-zone/README.md) | Monthly per zone | 🟢 |
| 16 | [RDS](rds/README.md) | [postgres-basic](rds/postgres-basic/README.md) | **Hourly** | 🟡 |

## How every lab works

```bash
cd aws-services/<service>/<lab>
terraform init
terraform plan
terraform apply
# verify with the commands in the lab README
terraform destroy
```

All labs use `var.aws_region` (default `us-east-1`) and `var.aws_profile` (default: the standard credential chain), and tag everything with `Project = terraform-aws-learning` and a `Lab` tag, so you can always find leftovers:

```bash
aws resourcegroupstaggingapi get-resources \
  --tag-filters Key=Project,Values=terraform-aws-learning \
  --query "ResourceTagMappingList[].ResourceARN"
```

## Projects that use these tracks

As you finish the relevant tracks, do the checkpoint projects: [02 Custom VPC](../projects/02-custom-vpc/README.md) (after VPC) · [03 Web server](../projects/03-web-server/README.md) and [04 VPC + EC2](../projects/04-vpc-ec2-stack/README.md) (after EC2) · [05 Secure S3](../projects/05-secure-s3/README.md) (after KMS) · [06 Serverless](../projects/06-serverless-application/README.md) (after Lambda) · [07 Event-driven](../projects/07-event-driven-architecture/README.md) (after SNS).

---

[← 10 · Expressions and Functions](../docs/10-expressions-and-functions/README.md) | [🏠 Home](../README.md) | [📚 Learning Path](../docs/00-learning-roadmap/README.md) | [S3 →](s3/README.md)
