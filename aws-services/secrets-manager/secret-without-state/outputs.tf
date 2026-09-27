# Only METADATA is exported. Never output a secret value: outputs are
# stored in state and shown by `terraform output -json`.

output "secret_arn" {
  description = "ARN of the secret (safe to share; it is not the value)."
  value       = aws_secretsmanager_secret.db.arn
}

output "read_policy_arn" {
  description = "Attach this policy to the role of the app that needs the password."
  value       = aws_iam_policy.read_secret.arn
}
