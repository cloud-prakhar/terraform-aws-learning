[⬆ Examples](../../README.md) | [🏠 Home](../../../README.md) | [📚 Learning Path](../../../docs/00-learning-roadmap/README.md)

# Lab · CLI workspaces

🟡 Intermediate · [Chapter 14](../../../docs/14-workspaces-and-environments/README.md) · 💰 Free (idle queues, empty buckets)

## What will be created — per workspace

| Resource | Name | Differs by workspace |
| --- | --- | --- |
| `aws_sqs_queue.events` | `tf-learning-<workspace>-events` | retention: 1 hour (dev/default) or 14 days (prod) |
| `aws_s3_bucket.data` + versioning | `tf-learning-<workspace>-data-...` | versioning on only in prod |

## Steps

```bash
terraform init
terraform workspace list                 # * default
terraform workspace new dev              # creates and selects "dev"
terraform apply
terraform workspace new prod
terraform plan                           # a completely separate state: plans to create everything again
terraform apply
terraform workspace list                 # default, dev, * prod
ls terraform.tfstate.d/                  # dev/  prod/  (local backend layout)
terraform workspace select dev
terraform output workspace               # "dev"
```

## Cleanup — once per workspace

```bash
terraform workspace select prod && terraform destroy
terraform workspace select dev  && terraform destroy
terraform workspace select default
terraform workspace delete prod
terraform workspace delete dev
```

---

[⬆ Examples](../../README.md) | [🏠 Home](../../../README.md) | [📚 Learning Path](../../../docs/00-learning-roadmap/README.md)
