[⬆ Terraform on AWS](README.md) | [🏠 Home](README.md) | [📚 Learning Path](docs/00-learning-roadmap/README.md)

# Security

## Reporting a vulnerability

If you find a security problem in this repository — for example, an example that would expose data or grant excessive permissions if deployed as written — please **do not open a public issue**. Use GitHub's [private vulnerability reporting](https://docs.github.com/en/code-security/security-advisories/guidance-on-reporting-and-writing-information-about-vulnerabilities/privately-reporting-a-security-vulnerability) on this repository instead.

## Using this repository safely

This is learning material. It is designed to be safe to run in a **personal or sandbox AWS account**, but:

- **Never run labs in a production account.** Some labs deliberately use shortcuts (e.g. `force_destroy = true`, `skip_final_snapshot = true`, HTTP-only load balancers). Each is marked `LEARNING SHORTCUT` in the code.
- **Destroy what you create.** Some resources are billed per hour. Every lab ends with cleanup steps.
- **Set a budget alert** in your AWS account before starting.

## Secrets and credentials

- The repository contains **no** credentials and no real secret values. Example values are placeholders.
- Never commit AWS keys, `terraform.tfstate`, `*.tfvars` with real values, or plan files. The [.gitignore](.gitignore) blocks the common cases, and the [pre-commit configuration](.pre-commit-config.yaml) runs `gitleaks`, `detect-private-key` and `detect-aws-credentials`.
- Terraform **state can contain secrets** even when variables are marked `sensitive`. See [Chapter 11](docs/11-terraform-state/README.md#7-state-security) and [Chapter 12](docs/12-remote-state/README.md).
- If you accidentally commit a credential: **revoke/rotate it immediately** in AWS first, then remove it from Git history. Removing the commit alone is not enough — assume it was copied.

## CI/CD

- Workflows authenticate to AWS with **GitHub OIDC** and short-lived credentials; no AWS keys are stored in GitHub ([Chapter 18](docs/18-github-actions/README.md)).
- Pull-request plans use a **read-only** role; applies require the protected `dev`/`prod` GitHub environments.
- All third-party actions are pinned to full commit SHAs.

---

[⬆ Terraform on AWS](README.md) | [🏠 Home](README.md) | [📚 Learning Path](docs/00-learning-roadmap/README.md)
