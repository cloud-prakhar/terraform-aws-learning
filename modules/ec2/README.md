[⬆ Reusable modules](../README.md) | [🏠 Home](../../README.md) | [📚 Learning Path](../../docs/00-learning-roadmap/README.md)

# Module · ec2

N identical EC2 instances spread round-robin over the given subnets, with their own security group. Concepts: [EC2 track](../../aws-services/ec2/README.md).

## What it creates

| Resource | Notes |
| --- | --- |
| `aws_security_group` | `name_prefix` + `create_before_destroy` |
| `aws_vpc_security_group_ingress_rule` (for_each) | From `ingress_rules`: CIDR **or** source security group per rule |
| `aws_vpc_security_group_egress_rule` | All outbound |
| `aws_instance` (for_each) | Keys `<name>-01`, `<name>-02`, …; IMDSv2 required; encrypted gp3 root; `ignore_changes = [ami]` |

AMI: `ami_id` if given, otherwise the latest Amazon Linux 2023 x86_64 (looked up only when needed).

## Usage

```hcl
module "web" {
  source = "../../modules/ec2"

  name                 = "myapp-dev-web"
  vpc_id               = module.vpc.vpc_id
  subnet_ids           = module.vpc.private_subnet_ids
  instance_count       = 2
  iam_instance_profile = module.app_role.instance_profile_name

  ingress_rules = {
    http-from-alb = {
      description              = "HTTP from the load balancer"
      port                     = 80
      source_security_group_id = aws_security_group.alb.id
    }
  }
}
```

- Example: [examples/basic](examples/basic/main.tf)
- Tests: [tests/ec2.tftest.hcl](tests/ec2.tftest.hcl)

## Design notes

- Instance keys are **names**, so the plan says `module.web.aws_instance.this["myapp-dev-web-02"]` rather than `[1]`. Reducing `instance_count` still removes the highest numbers first.
- `ignore_changes = [ami]` means new AMIs are **not** rolled out automatically. For fleets that should roll automatically, use a launch template and Auto Scaling ([Project 08](../../projects/08-highly-available-web/README.md)).

<!-- BEGIN_TF_DOCS -->
### Requirements

| Name | Version |
| ---- | ------- |
| terraform | >= 1.11.0 |
| aws | >= 6.0 |

### Providers

| Name | Version |
| ---- | ------- |
| aws | >= 6.0 |

### Resources

| Name | Type |
| ---- | ---- |
| [aws_instance.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/instance) | resource |
| [aws_security_group.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [aws_vpc_security_group_egress_rule.all](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_security_group_egress_rule) | resource |
| [aws_vpc_security_group_ingress_rule.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_security_group_ingress_rule) | resource |
| [aws_ami.al2023](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ami) | data source |

### Inputs

| Name | Description | Type | Default | Required |
| ---- | ----------- | ---- | ------- | :------: |
| name | Name prefix for the instances and security group. | `string` | n/a | yes |
| subnet\_ids | Subnets to place instances in. Instances are spread round-robin across them. | `list(string)` | n/a | yes |
| vpc\_id | VPC in which to create the security group. | `string` | n/a | yes |
| ami\_id | AMI to launch. When null, the latest Amazon Linux 2023 x86\_64 AMI is used. | `string` | `null` | no |
| associate\_public\_ip | Give instances a public IPv4 address (billed hourly). Only works in public subnets. | `bool` | `false` | no |
| iam\_instance\_profile | Name of an IAM instance profile to attach, or null. | `string` | `null` | no |
| ingress\_rules | Inbound rules for the instance security group. Use either cidr\_ipv4 or source\_security\_group\_id per rule. | ```map(object({ description = string port = number protocol = optional(string, "tcp") cidr_ipv4 = optional(string) source_security_group_id = optional(string) }))``` | `{}` | no |
| instance\_count | Number of instances to create. | `number` | `1` | no |
| instance\_type | EC2 instance type. | `string` | `"t3.micro"` | no |
| root\_volume\_size\_gb | Root EBS volume size in GiB. | `number` | `8` | no |
| tags | Tags to add to every resource. | `map(string)` | `{}` | no |
| user\_data | Boot script (cloud-init). Changing it replaces the instances. | `string` | `null` | no |

### Outputs

| Name | Description |
| ---- | ----------- |
| instance\_ids | Map of instance name => instance ID. |
| private\_ips | Map of instance name => private IPv4 address. |
| public\_ips | Map of instance name => public IPv4 address (empty strings when none). |
| security\_group\_id | ID of the instances' security group, e.g. to allow it as a source elsewhere. |
<!-- END_TF_DOCS -->

---

[⬆ Reusable modules](../README.md) | [🏠 Home](../../README.md) | [📚 Learning Path](../../docs/00-learning-roadmap/README.md)
