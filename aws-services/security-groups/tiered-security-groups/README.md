[⬆ Security Groups](../README.md) | [🏠 Home](../../../README.md) | [📚 Learning Path](../../../docs/00-learning-roadmap/README.md)

# Lab · Tiered security groups

🟢 Beginner · [Security groups track](../README.md) · 💰 Free (security groups have no charge)

## What will be created

Three groups in your **default VPC** and the rules that chain them:

| Group | Inbound | Outbound |
| --- | --- | --- |
| `tf-learning-alb` | 80, 443 from `0.0.0.0/0` | 8080 to `app` group |
| `tf-learning-app` | 8080 from `alb` group | all |
| `tf-learning-db` | 5432 from `app` group | none (stateful replies still work) |

## Commands

```bash
terraform init
terraform apply
terraform output security_group_ids
```

## Verification

```bash
APP=$(terraform output -json security_group_ids | jq -r .app)
aws ec2 describe-security-group-rules --filters "Name=group-id,Values=$APP" \
  --query "SecurityGroupRules[].[IsEgress,IpProtocol,FromPort,ToPort,ReferencedGroupInfo.GroupId,CidrIpv4]" \
  --output table
```

(If you don't have `jq`, run `terraform output security_group_ids` and copy the `app` ID.)

In the EC2 console → Security Groups, open `tf-learning-app` → Inbound rules: the source is the **alb group ID**, not an IP address.

## Experiment

Add an SSH rule from `0.0.0.0/0` to the app group, run `terraform plan`, then run the security scanner from [Chapter 17](../../../docs/17-terraform-tooling/README.md) (`checkov -d .`) and read what it reports. Remove the rule again.

## Cleanup

```bash
terraform destroy
```

---

[⬆ Security Groups](../README.md) | [🏠 Home](../../../README.md) | [📚 Learning Path](../../../docs/00-learning-roadmap/README.md)
