[⬆ Terraform on AWS](README.md) | [🏠 Home](README.md) | [📚 Learning Path](docs/00-learning-roadmap/README.md)

# Contributing

Thanks for helping improve this course. Corrections to outdated commands, broken links and unclear explanations are the most valuable contributions.

## Principles

- **Accuracy first.** Check facts against official documentation (HashiCorp, Terraform Registry, AWS, GitHub) and link to it.
- **WHY → WHAT → HOW.** Every concept explains the problem it solves before the syntax.
- **One idea per lab.** Don't grow a lab until it teaches three things at once — add a new one, or extend a project.
- **Safe by default.** No credentials, no real secrets, no public buckets, cost warnings on anything billed by the hour or month, cleanup steps in every lab.
- **No filler.** If a page doesn't teach, demonstrate, practise or serve as reference, it doesn't belong.

## Local setup

Install Terraform (≥ 1.11), [TFLint](https://github.com/terraform-linters/tflint), [terraform-docs](https://terraform-docs.io/), [Checkov](https://www.checkov.io/) and [pre-commit](https://pre-commit.com/), then:

```bash
pre-commit install
```

## Before opening a pull request

```bash
terraform fmt -recursive
./scripts/validate-all.sh                              # init -backend=false + validate everywhere
tflint --init --config "$(pwd)/.tflint.hcl"
tflint --recursive --config "$(pwd)/.tflint.hcl"
checkov --config-file .checkov.yaml -d modules
checkov --config-file .checkov.yaml -d projects
for m in modules/*/; do terraform -chdir="$m" init -backend=false >/dev/null && terraform -chdir="$m" test; done
for m in modules/*/; do terraform-docs "$m"; done
python3 scripts/check-links.py
```

CI runs the same checks ([.github/workflows/terraform-check.yml](.github/workflows/terraform-check.yml)).

## Conventions

| Topic | Convention |
| --- | --- |
| Terraform files | `versions.tf`, `providers.tf`, `variables.tf`, `main.tf` (or topic files), `outputs.tf` |
| Versions | Root configs: `required_version = ">= 1.11.0"`, AWS `~> 6.0`, commit `.terraform.lock.hcl`. Modules: `>= 6.0`, no lock file. |
| Variables/outputs | Always `description`; variables always `type` |
| Names | `snake_case` identifiers; AWS names prefixed `tf-learning-`; `bucket_prefix`/`name_prefix` where uniqueness matters |
| Comments | Explain **why**, not what. Mark `COST` and `LEARNING SHORTCUT` explicitly. |
| Checkov | Fix findings in `modules/` and `projects/`, or add `#checkov:skip=ID:reason` next to the resource |
| Diagrams | Mermaid only, using the colour classes from existing pages |
| Lab READMEs | What is created · prerequisites · commands · verification · cost · cleanup |

## Adding a chapter or service track

Every learning page has a navigation bar at the top and bottom (Previous · Home · Learning Path · Next). When you add a page to the sequence, update the neighbouring pages' links and the [learning roadmap](docs/00-learning-roadmap/README.md), then run `python3 scripts/check-links.py`.

## Reporting a problem

Open an issue with the page link, what you expected, what happened, and your `terraform version` output. For security issues, see [SECURITY.md](SECURITY.md).

---

[⬆ Terraform on AWS](README.md) | [🏠 Home](README.md) | [📚 Learning Path](docs/00-learning-roadmap/README.md)
