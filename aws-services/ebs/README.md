[← EC2](../ec2/README.md) | [🏠 Home](../../README.md) | [📚 Learning Path](../../docs/00-learning-roadmap/README.md) | [⬆ AWS Service Tracks](../README.md) | [KMS →](../kms/README.md)

# EBS — Elastic Block Store

🟢 Beginner · Track 6 of 16 · Lab: [EC2 lab 02](../ec2/02-multiple-instances-with-ebs/README.md) · 💰 Billed per GB-month (and provisioned IOPS/throughput above the baseline) for as long as a volume exists

## What is it?

EBS provides **network-attached disks** (volumes) for EC2 instances. Every instance has a root volume; you can attach more.

## Why do we need it?

Data on a separate EBS volume survives when the instance is replaced (new AMI, resize, failure), can be snapshotted for backup, and can be resized independently.

## How does it work?

| Concept | What to know |
| --- | --- |
| **AZ-scoped** | A volume lives in one AZ and can only attach to instances in that AZ. |
| **Volume types** | `gp3` (general purpose SSD, baseline IOPS/throughput included, tunable) is the sensible default. `io2` for high IOPS databases; `st1`/`sc1` HDD for throughput/cold data. |
| **Encryption** | Set `encrypted = true` (AWS managed key `aws/ebs`) or pass `kms_key_id`. You can also turn on **EBS encryption by default** for the whole account/Region. |
| **Snapshots** | Point-in-time, incremental backups stored in S3 (managed by AWS). Automate with AWS Backup or Data Lifecycle Manager. |
| **Device names** | You attach as `/dev/sdf`; on Nitro instances Linux shows it as an NVMe device (`/dev/nvme1n1`). |

### Simple analogy

The instance is a laptop; an EBS volume is an **external drive** plugged in through a cable that only reaches desks in the same room (AZ).

## How Terraform models EBS

```hcl
resource "aws_ebs_volume" "data" {
  availability_zone = aws_instance.server.availability_zone   # must match the instance
  size              = 10
  type              = "gp3"
  encrypted         = true
}

resource "aws_volume_attachment" "data" {
  device_name = "/dev/sdf"
  volume_id   = aws_ebs_volume.data.id
  instance_id = aws_instance.server.id
}
```

Root volumes are configured **inside** `aws_instance` with `root_block_device { }`. Avoid `ebs_block_device { }` inside `aws_instance` for data disks: separate `aws_ebs_volume` resources are easier to manage, resize and protect.

### Protecting data

- `lifecycle { prevent_destroy = true }` on volumes holding important data.
- Snapshots before risky changes; AWS Backup for schedules.
- Removing the attachment or the instance from Terraform does **not** delete the separate volume; removing the `aws_ebs_volume` resource does.

## Lab

The EBS resources are part of **[EC2 lab 02](../ec2/02-multiple-instances-with-ebs/README.md)**: one data volume per instance, created with `for_each` in the matching AZ.

## Key takeaways

- EBS volumes are AZ-scoped network disks; `gp3` + `encrypted = true` is the default choice.
- Use separate `aws_ebs_volume` + `aws_volume_attachment` for data disks.
- Volumes are billed while they exist — attached or not.

## Official references

- [Amazon EBS User Guide](https://docs.aws.amazon.com/ebs/latest/userguide/what-is-ebs.html)
- [EBS volume types](https://docs.aws.amazon.com/ebs/latest/userguide/ebs-volume-types.html)
- [EBS encryption](https://docs.aws.amazon.com/ebs/latest/userguide/ebs-encryption.html)
- [aws_ebs_volume (Terraform)](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ebs_volume)

---

[← EC2](../ec2/README.md) | [🏠 Home](../../README.md) | [📚 Learning Path](../../docs/00-learning-roadmap/README.md) | [⬆ AWS Service Tracks](../README.md) | [KMS →](../kms/README.md)
