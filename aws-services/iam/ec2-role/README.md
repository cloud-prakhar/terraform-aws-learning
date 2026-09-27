[⬆ IAM](../README.md) | [🏠 Home](../../../README.md) | [📚 Learning Path](../../../docs/00-learning-roadmap/README.md)

# Lab · IAM role for EC2

🟢 Beginner · [IAM track](../README.md) · 💰 Free (IAM and an empty bucket cost nothing)

## What will be created

| Resource | IAM concept |
| --- | --- |
| `aws_s3_bucket.app_config` | The data the role may read |
| `aws_iam_role.app` + `data.aws_iam_policy_document.ec2_trust` | Role with a **trust policy** for `ec2.amazonaws.com` |
| `aws_iam_policy.read_config` | **Customer managed** permissions policy: `s3:ListBucket` (only prefix `config/`) and `s3:GetObject` on `config/*` |
| `aws_iam_role_policy_attachment.read_config` | Attaches it to the role |
| `aws_iam_role_policy_attachment.ssm` | Attaches the **AWS managed** `AmazonSSMManagedInstanceCore` policy |
| `aws_iam_instance_profile.app` | Lets EC2 use the role |

## Commands

```bash
terraform init
terraform apply
terraform output
```

## Verification

```bash
aws iam get-role --role-name tf-learning-app-role --query "Role.AssumeRolePolicyDocument"
aws iam list-attached-role-policies --role-name tf-learning-app-role
aws iam get-policy-version --policy-arn "$(terraform output -raw policy_arn)" --version-id v1 \
  --query "PolicyVersion.Document"
```

**Try the IAM policy simulator** (no instance needed):

```bash
ROLE_ARN=$(terraform output -raw role_arn)
BUCKET=$(terraform output -raw config_bucket)
aws iam simulate-principal-policy --policy-source-arn "$ROLE_ARN" \
  --action-names s3:GetObject s3:PutObject \
  --resource-arns "arn:aws:s3:::$BUCKET/config/app.json" \
  --query "EvaluationResults[].[EvalActionName,EvalDecision]" --output table
```

Expect `s3:GetObject` → `allowed` and `s3:PutObject` → `implicitDeny`.

## Cleanup

```bash
terraform destroy
```

---

[⬆ IAM](../README.md) | [🏠 Home](../../../README.md) | [📚 Learning Path](../../../docs/00-learning-roadmap/README.md)
