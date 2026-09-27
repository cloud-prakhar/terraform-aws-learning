# GitHub Actions → AWS without long-lived keys:
#   1. The workflow requests a signed OIDC token from GitHub.
#   2. AWS STS verifies the token against this identity provider.
#   3. If the token's claims match a role's TRUST policy, STS returns
#      temporary credentials (valid for about an hour).

data "aws_caller_identity" "current" {}

locals {
  oidc_host = "token.actions.githubusercontent.com"
  oidc_provider_arn = var.create_oidc_provider ? aws_iam_openid_connect_provider.github[0].arn : (
    "arn:aws:iam::${data.aws_caller_identity.current.account_id}:oidc-provider/${local.oidc_host}"
  )
  state_bucket_arn = module.state_bucket.bucket_arn
}

resource "aws_iam_openid_connect_provider" "github" {
  count = var.create_oidc_provider ? 1 : 0

  url            = "https://${local.oidc_host}"
  client_id_list = ["sts.amazonaws.com"]
  # thumbprint_list is optional: AWS validates GitHub's certificate
  # through its own trusted certificate authorities.
}

# ---------------------------------------------------------------------------
# PLAN role – assumed by pull-request workflows. READ-ONLY on purpose:
# a pull request can change Terraform code, and Terraform code can run
# arbitrary logic during plan (providers, external data sources), so a
# plan job must never hold write permissions.
# ---------------------------------------------------------------------------

data "aws_iam_policy_document" "plan_trust" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]

    principals {
      type        = "Federated"
      identifiers = [local.oidc_provider_arn]
    }

    condition {
      test     = "StringEquals"
      variable = "${local.oidc_host}:aud"
      values   = ["sts.amazonaws.com"]
    }

    # Only pull-request runs of THIS repository.
    condition {
      test     = "StringEquals"
      variable = "${local.oidc_host}:sub"
      values   = ["repo:${var.github_repository}:pull_request"]
    }
  }
}

resource "aws_iam_role" "plan" {
  name                 = "github-${var.app_name}-terraform-plan"
  description          = "Read-only Terraform plan from GitHub pull requests"
  assume_role_policy   = data.aws_iam_policy_document.plan_trust.json
  max_session_duration = 3600
}

resource "aws_iam_role_policy_attachment" "plan_read_only" {
  role       = aws_iam_role.plan.name
  policy_arn = "arn:aws:iam::aws:policy/ReadOnlyAccess"
}

# Plan acquires the state lock, so it needs to create and delete the
# .tflock object (nothing else is writable).
data "aws_iam_policy_document" "plan_lock" {
  statement {
    actions   = ["s3:PutObject", "s3:DeleteObject"]
    resources = ["${local.state_bucket_arn}/*.tflock"]
  }
}

resource "aws_iam_role_policy" "plan_lock" {
  name   = "state-lock"
  role   = aws_iam_role.plan.id
  policy = data.aws_iam_policy_document.plan_lock.json
}

# ---------------------------------------------------------------------------
# APPLY roles – one per GitHub Environment. The trust policy only accepts
# jobs that run in that environment, so environment protection rules
# (required reviewers, branch restrictions) gate who can deploy.
# ---------------------------------------------------------------------------

data "aws_iam_policy_document" "apply_trust" {
  for_each = var.environments

  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]

    principals {
      type        = "Federated"
      identifiers = [local.oidc_provider_arn]
    }

    condition {
      test     = "StringEquals"
      variable = "${local.oidc_host}:aud"
      values   = ["sts.amazonaws.com"]
    }

    condition {
      test     = "StringEquals"
      variable = "${local.oidc_host}:sub"
      values   = ["repo:${var.github_repository}:environment:${each.key}"]
    }
  }
}

resource "aws_iam_role" "apply" {
  for_each = var.environments

  name                 = "github-${var.app_name}-terraform-apply-${each.key}"
  description          = "Terraform apply for ${each.key} from GitHub Actions"
  assume_role_policy   = data.aws_iam_policy_document.apply_trust[each.key].json
  max_session_duration = 3600
}

# Permissions are limited to what modules/application-stack creates, and
# to names starting with "<app>-<env>-" where AWS supports it.
data "aws_iam_policy_document" "apply" {
  for_each = var.environments

  statement {
    sid       = "StateReadWrite"
    actions   = ["s3:GetObject", "s3:PutObject", "s3:DeleteObject"]
    resources = ["${local.state_bucket_arn}/projects/09/${each.key}/*"]
  }

  statement {
    sid       = "StateList"
    actions   = ["s3:ListBucket"]
    resources = [local.state_bucket_arn]
  }

  # EC2 networking and instances. EC2 resource names are tags, which are
  # not usable for every action, so this is scoped to the Region instead.
  statement {
    sid       = "Ec2InRegion"
    actions   = ["ec2:*"]
    resources = ["*"]

    condition {
      test     = "StringEquals"
      variable = "aws:RequestedRegion"
      values   = [var.aws_region]
    }
  }

  statement {
    sid     = "AppBuckets"
    actions = ["s3:*"]
    resources = [
      "arn:aws:s3:::${var.app_name}-${each.key}-*",
      "arn:aws:s3:::${var.app_name}-${each.key}-*/*",
    ]
  }

  statement {
    sid = "AppRolesAndProfiles"
    actions = [
      "iam:CreateRole", "iam:DeleteRole", "iam:GetRole", "iam:UpdateRole",
      "iam:UpdateRoleDescription", "iam:TagRole", "iam:UntagRole",
      "iam:ListRolePolicies", "iam:ListAttachedRolePolicies",
      "iam:ListInstanceProfilesForRole",
      "iam:PutRolePolicy", "iam:GetRolePolicy", "iam:DeleteRolePolicy",
      "iam:CreateInstanceProfile", "iam:DeleteInstanceProfile",
      "iam:GetInstanceProfile", "iam:TagInstanceProfile",
      "iam:UntagInstanceProfile", "iam:AddRoleToInstanceProfile",
      "iam:RemoveRoleFromInstanceProfile",
    ]
    resources = [
      "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/${var.app_name}-${each.key}-*",
      "arn:aws:iam::${data.aws_caller_identity.current.account_id}:instance-profile/${var.app_name}-${each.key}-*",
    ]
  }

  # Without this condition the pipeline could attach AdministratorAccess
  # to a role it creates: a classic privilege-escalation path.
  statement {
    sid       = "AttachOnlyApprovedManagedPolicies"
    actions   = ["iam:AttachRolePolicy", "iam:DetachRolePolicy"]
    resources = ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/${var.app_name}-${each.key}-*"]

    condition {
      test     = "ArnEquals"
      variable = "iam:PolicyARN"
      values   = ["arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"]
    }
  }

  statement {
    sid       = "PassAppRoleToEc2Only"
    actions   = ["iam:PassRole"]
    resources = ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/${var.app_name}-${each.key}-*"]

    condition {
      test     = "StringEquals"
      variable = "iam:PassedToService"
      values   = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_role_policy" "apply" {
  for_each = var.environments

  name   = "terraform-apply"
  role   = aws_iam_role.apply[each.key].id
  policy = data.aws_iam_policy_document.apply[each.key].json
}
