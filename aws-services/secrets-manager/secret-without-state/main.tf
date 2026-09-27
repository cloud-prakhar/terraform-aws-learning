# COST: each secret has a monthly charge plus a per-API-call charge.

# The secret is a CONTAINER (name, description, encryption key, policy).
# Its value lives in separate "versions".
resource "aws_secretsmanager_secret" "db" {
  name        = var.secret_name
  description = "Database password for the demo app"

  # Encrypted with the AWS managed key aws/secretsmanager by default.
  # Set kms_key_id to use a customer managed key (see aws-services/kms).

  # LEARNING SHORTCUT: 0 deletes immediately on destroy so you can re-run
  # the lab with the same name. In production keep the default
  # (30 days), which lets you recover an accidentally deleted secret.
  recovery_window_in_days = 0
}

# EPHEMERAL resource (Terraform 1.10+): the password is generated during
# the run, used, and then forgotten. It is NEVER written to the plan or
# state file.
ephemeral "aws_secretsmanager_random_password" "db" {
  password_length     = 32
  exclude_punctuation = true
}

# WRITE-ONLY argument (Terraform 1.11+): secret_string_wo is sent to AWS
# but not stored in state. Because Terraform cannot compare a value it
# never stored, you tell it when to write again by bumping the version.
resource "aws_secretsmanager_secret_version" "db" {
  secret_id                = aws_secretsmanager_secret.db.id
  secret_string_wo         = ephemeral.aws_secretsmanager_random_password.db.random_password
  secret_string_wo_version = var.password_version
}

# --- Letting an application read the secret ----------------------------
# Applications fetch the value at runtime with their own IAM role, so
# the value never needs to pass through Terraform outputs.

data "aws_iam_policy_document" "read_secret" {
  statement {
    sid       = "ReadDbPassword"
    actions   = ["secretsmanager:GetSecretValue"]
    resources = [aws_secretsmanager_secret.db.arn]
  }
}

resource "aws_iam_policy" "read_secret" {
  name        = "tf-learning-read-db-password"
  description = "Allows reading only the demo database password"
  policy      = data.aws_iam_policy_document.read_secret.json
}
