# TRUST policy: WHO may assume this role.
data "aws_iam_policy_document" "trust" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = var.trusted_services
    }
  }
}

resource "aws_iam_role" "this" {
  name               = var.name
  description        = var.description
  assume_role_policy = data.aws_iam_policy_document.trust.json
  tags               = var.tags
}

# PERMISSIONS policies: WHAT the role may do once assumed.
# toset() turns the list into keys so removing one ARN does not shift
# the others (see count vs for_each in Chapter 09).
resource "aws_iam_role_policy_attachment" "managed" {
  for_each = toset(var.managed_policy_arns)

  role       = aws_iam_role.this.name
  policy_arn = each.value
}

# for_each over a map with STATIC keys: Terraform knows how many policies
# exist at plan time even when the JSON values are not known until apply
# (e.g. they contain the ARN of a bucket created in the same run).
resource "aws_iam_role_policy" "inline" {
  for_each = var.inline_policies

  name   = each.key
  role   = aws_iam_role.this.id
  policy = each.value
}

# EC2 cannot use a role directly; it needs this wrapper.
resource "aws_iam_instance_profile" "this" {
  count = var.create_instance_profile ? 1 : 0

  name = var.name
  role = aws_iam_role.this.name
  tags = var.tags
}
