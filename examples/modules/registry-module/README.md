[⬆ Module labs](../README.md) | [🏠 Home](../../../README.md) | [📚 Learning Path](../../../docs/00-learning-roadmap/README.md)

# Lab · Using a registry module

🟡 Intermediate · [Chapter 13](../../../docs/13-terraform-modules/README.md) · 💰 Free (VPC, subnets and IGW have no charge; NAT is disabled)

## What will be created

A VPC with two public and two private subnets, route tables and an internet gateway, built by the community module [terraform-aws-modules/vpc/aws](https://registry.terraform.io/modules/terraform-aws-modules/vpc/aws/latest), pinned with `version = "~> 6.7"`.

## Commands

```bash
terraform init          # downloads the module into .terraform/modules/
ls .terraform/modules/vpc
terraform plan
terraform apply
terraform output
```

## Things to look at

- `.terraform/modules/modules.json` records which version was installed.
- The module's [inputs](https://registry.terraform.io/modules/terraform-aws-modules/vpc/aws/latest?tab=inputs) — there are many; you set only what you need.
- Compare the plan with your own [VPC labs](../../../aws-services/vpc/README.md) and [modules/vpc](../../../modules/vpc/README.md): same concepts, more options.

## Cleanup

```bash
terraform destroy
```

---

[⬆ Module labs](../README.md) | [🏠 Home](../../../README.md) | [📚 Learning Path](../../../docs/00-learning-roadmap/README.md)
