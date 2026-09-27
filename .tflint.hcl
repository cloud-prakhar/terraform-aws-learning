# TFLint configuration used locally, by pre-commit and by CI.
# Docs: https://github.com/terraform-linters/tflint/blob/master/docs/user-guide/config.md
#
# Run from the repository root:
#   tflint --init
#   tflint --recursive --config "$(pwd)/.tflint.hcl"

config {
  # Also lint module calls with local sources (e.g. ../../modules/s3).
  call_module_type = "local"
}

# Core Terraform language rules: unused declarations, missing types,
# missing version constraints, deprecated syntax, naming, ...
plugin "terraform" {
  enabled = true
  preset  = "recommended"
}

# AWS-specific rules: invalid instance types, invalid AMI formats,
# previous-generation instance types, and many more.
# Pinned so every learner and CI run use the same rule set.
plugin "aws" {
  enabled = true
  version = "0.49.0"
  source  = "github.com/terraform-linters/tflint-ruleset-aws"
}

# Every variable and output in this course must explain itself.
rule "terraform_documented_variables" {
  enabled = true
}

rule "terraform_documented_outputs" {
  enabled = true
}

rule "terraform_naming_convention" {
  enabled = true
  format  = "snake_case"
}
