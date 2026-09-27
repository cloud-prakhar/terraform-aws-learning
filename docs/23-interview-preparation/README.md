[← 22 · Troubleshooting](../22-troubleshooting/README.md) | [🏠 Home](../../README.md) | [📚 Learning Path](../00-learning-roadmap/README.md) | [Projects →](../../projects/README.md)

# 23 · Interview Preparation

🟢🟡 Reference · Questions grouped by level, with answers that explain the *why*

Don't memorise these answers — use them to check that you can explain each idea in your own words, ideally with an example from the labs you ran. Each answer links to the chapter that covers it.

- [Beginner](#beginner)
- [Intermediate](#intermediate)
- [Scenario-based](#scenario-based)

---

## Beginner

<details>
<summary><strong>What is Infrastructure as Code, and why use it?</strong></summary>

Describing infrastructure in version-controlled files that a tool applies. Benefits: repeatability (same code → same environment), review (changes go through pull requests), history (Git shows who changed what), speed of recovery (re-apply to rebuild), and documentation (the code *is* the description). → [Ch. 01](../01-terraform-introduction/README.md)
</details>

<details>
<summary><strong>Declarative vs imperative?</strong></summary>

Imperative tools execute steps you list ("create a VPC, then a subnet"); running them twice may create duplicates. Declarative tools take a desired end state and compute the steps; running them again does nothing if reality already matches (idempotency). Terraform is declarative. → [Ch. 01](../01-terraform-introduction/README.md#2-declarative-vs-imperative)
</details>

<details>
<summary><strong>What does <code>terraform init</code> do?</strong></summary>

Prepares the working directory: configures the backend, downloads modules, installs providers that satisfy the version constraints and the lock file, and creates/updates `.terraform.lock.hcl`. It doesn't touch infrastructure and is safe to re-run. → [Ch. 05](../05-terraform-workflow/README.md#1-terraform-init)
</details>

<details>
<summary><strong>What happens during <code>terraform plan</code>?</strong></summary>

Terraform reads the state, **refreshes** it by asking the provider for the current settings of every managed object, compares the configuration with that refreshed state, and prints the actions needed (create, update, replace, destroy). Nothing is changed. The refresh is also how drift is detected. → [Ch. 05](../05-terraform-workflow/README.md#4-terraform-plan)
</details>

<details>
<summary><strong>What is Terraform state, and why does Terraform need it?</strong></summary>

A record mapping each resource address in the code to the real object ID and its attributes. Without it Terraform couldn't tell which real bucket is `aws_s3_bucket.logs`, couldn't delete things removed from the code, and couldn't order deletes. → [Ch. 11](../11-terraform-state/README.md)
</details>

<details>
<summary><strong>Resource vs data source?</strong></summary>

A `resource` is created, updated and destroyed by Terraform. A `data` source only reads something that already exists (latest AMI, account ID, an existing VPC) — Terraform never modifies it. → [Ch. 08](../08-data-sources-and-locals/README.md)
</details>

<details>
<summary><strong>Variables vs locals vs outputs?</strong></summary>

Variables are inputs set from outside (tfvars, `-var`, module arguments). Locals are internal named values computed in the configuration, not settable from outside. Outputs expose values after evaluation, to people, scripts, or a calling module. → [Ch. 07](../07-variables-and-outputs/README.md), [Ch. 08](../08-data-sources-and-locals/README.md)
</details>

<details>
<summary><strong>How does Terraform know in which order to create resources?</strong></summary>

From references: if resource B uses an attribute of resource A, B depends on A. Terraform builds a dependency graph, creates independent resources in parallel, and destroys in reverse order. `depends_on` adds dependencies it can't infer. → [Ch. 01](../01-terraform-introduction/README.md#6-the-dependency-graph)
</details>

<details>
<summary><strong>Which files should be committed?</strong></summary>

Commit `*.tf`, `.terraform.lock.hcl` (root modules), and example tfvars. Don't commit `.terraform/`, `*.tfstate*`, plan files, or real `*.tfvars` containing environment-specific or secret values. → [Ch. 03](../03-terraform-basics/README.md#3-configuration-files)
</details>

<details>
<summary><strong>What does <code>sensitive = true</code> do?</strong></summary>

It redacts a value in plan/apply output and marks derived values as sensitive. It does **not** encrypt the value or keep it out of state or plan files. → [Ch. 07](../07-variables-and-outputs/README.md#sensitive-variables)
</details>

---

## Intermediate

<details>
<summary><strong><code>count</code> vs <code>for_each</code>?</strong></summary>

`count` identifies instances by index; `for_each` by key. Removing a middle element from a list used with `count` shifts later indexes, so Terraform replaces or destroys unrelated resources. With `for_each`, only the removed key is affected. Use `count` for N identical copies or optional (0/1) resources; `for_each` when items have identities. → [Ch. 09](../09-meta-arguments/README.md#3-count-vs-for_each)
</details>

<details>
<summary><strong>What is a backend? Why remote state?</strong></summary>

The backend decides where state is stored. Remote backends (S3, HCP Terraform) let a team and CI share one state, provide locking, keep history (versioning), and keep secrets off laptops with encryption and access control. → [Ch. 12](../12-remote-state/README.md)
</details>

<details>
<summary><strong>How do teams prevent concurrent state modification?</strong></summary>

State locking. With the S3 backend, `use_lockfile = true` creates a `.tflock` object using a conditional write; a second run can't acquire it and waits or fails. DynamoDB-based locking is the older approach and is deprecated in current Terraform. Pipelines also serialise applies per environment (e.g. GitHub `concurrency`). → [Ch. 12](../12-remote-state/README.md#3-state-locking)
</details>

<details>
<summary><strong>How do modules work?</strong></summary>

A module is a directory of `.tf` files. The root module calls child modules with `module` blocks; inputs are passed as arguments (the module's variables) and results come back as outputs. The child can't see the caller's values except those passed in. Remote modules should be version-pinned. → [Ch. 13](../13-terraform-modules/README.md)
</details>

<details>
<summary><strong>What are workspaces used for?</strong></summary>

CLI workspaces give one configuration several independent states (`terraform.workspace` holds the name). Good for temporary or identical copies. They share the backend and credentials, so for long-lived environments that need separate access control, directory-per-environment is usually preferred. → [Ch. 14](../14-workspaces-and-environments/README.md)
</details>

<details>
<summary><strong>How do you rename a resource without destroying it?</strong></summary>

Add a `moved { from = ... to = ... }` block. The plan shows the move and no destroy/create. It's reviewable and works for everyone sharing the state, unlike `terraform state mv`. → [Ch. 11](../11-terraform-state/README.md#6-refactoring-moved-and-removed-blocks)
</details>

<details>
<summary><strong>What are lifecycle arguments?</strong></summary>

`create_before_destroy` (replacement order), `prevent_destroy` (fail plans that destroy), `ignore_changes` (attributes managed elsewhere), `replace_triggered_by` (replace when something else changes), and pre/postconditions. → [Ch. 09](../09-meta-arguments/README.md#6-lifecycle)
</details>

<details>
<summary><strong>How do you test Terraform?</strong></summary>

Layers: `fmt -check`, `validate`, variable validation, TFLint, a security scanner, `terraform test` (plan with mocked providers for logic; apply in a sandbox for integration), plan review in PRs, and pre/postconditions and `check` blocks in the code. → [Ch. 16](../16-testing-and-validation/README.md)
</details>

<details>
<summary><strong>What is HCP Terraform? What is Terraform Enterprise?</strong></summary>

HCP Terraform (formerly Terraform Cloud) is HashiCorp's SaaS platform: remote state and runs, VCS integration, teams, private registry, policies (Sentinel/OPA), run tasks and dynamic credentials. Terraform Enterprise is the self-hosted distribution of HCP Terraform, chosen for data residency, private networking, SSO and audit requirements. → [Ch. 19](../19-hcp-terraform/README.md), [Ch. 20](../20-terraform-enterprise/README.md)
</details>

---

## Scenario-based

<details>
<summary><strong>Someone changed a security group in the console. What happens next time you run Terraform?</strong></summary>

`plan` refreshes, sees the difference, reports "changed outside of Terraform", and proposes to revert to the code. If the manual change was intentional, put it in the code (or, if another system legitimately manages that attribute, use `ignore_changes`). Use `plan -refresh-only` to see drift without proposing infrastructure changes.
</details>

<details>
<summary><strong>How would you import existing AWS infrastructure?</strong></summary>

Identify resources and their import IDs; write `import` blocks (with `for_each` for many); write matching `resource` blocks — optionally drafting them with `terraform plan -generate-config-out` and cleaning up; iterate until the plan shows only imports and no changes; review in a PR; apply. Remember to import sub-resources (e.g. S3 versioning/encryption) too. → [Ch. 15](../15-import-and-existing-resources/README.md)
</details>

<details>
<summary><strong>How would you secure Terraform state?</strong></summary>

Remote S3 backend with encryption (optionally a customer managed KMS key), versioning, public access blocked, HTTPS-only policy, `prevent_destroy`, native locking; IAM that limits read/write per state key and environment; no secrets in state where possible (managed passwords, ephemeral resources, write-only arguments); never commit state. → [Ch. 12](../12-remote-state/README.md)
</details>

<details>
<summary><strong>How should GitHub Actions authenticate to AWS?</strong></summary>

With OIDC: the job requests a GitHub-signed token (`id-token: write`); AWS STS validates it against an IAM OIDC provider and a role trust policy that checks `aud = sts.amazonaws.com` and a specific `sub` (repository + environment/branch/pull_request); the job receives temporary credentials. No stored access keys. Use a read-only role for PR plans and per-environment apply roles gated by GitHub environment protection. → [Ch. 18](../18-github-actions/README.md)
</details>

<details>
<summary><strong>A plan shows <code>-/+</code> on your production database. What do you do?</strong></summary>

Stop. Find the attribute marked `# forces replacement`. Common causes: an identifier/name change, an engine or storage setting that can't be modified in place, a changed AMI/subnet, or a refactor without `moved`. Fix the code (revert, add `moved`, use `ignore_changes` if another process owns the attribute), or plan a controlled migration (snapshot, blue/green). Protect such resources with `prevent_destroy` and deletion protection in the first place.
</details>

<details>
<summary><strong>An apply failed halfway. What is the state now?</strong></summary>

Terraform writes state after each resource, so everything that succeeded is recorded; the failed resource isn't (or is marked tainted if created but not fully configured). Fix the cause and run `apply` again — Terraform continues from reality. If a resource was created but not recorded ("already exists" next time), import it.
</details>

<details>
<summary><strong>The state is locked and CI is blocked. What do you do?</strong></summary>

Read the lock info (who, when, operation). Check whether that run is still active (CI run list, colleague). Only if nothing is running, `terraform force-unlock <ID>`. Then find out why the lock was left behind (killed runner, cancelled apply) and fix that — e.g. `cancel-in-progress: false` for apply jobs.
</details>

<details>
<summary><strong>How would you structure Terraform for dev, staging and prod?</strong></summary>

Reusable modules for the building blocks; one thin root module per environment (directory) that calls them with environment-specific inputs; separate state keys (and ideally AWS accounts) per environment; a pipeline that applies to dev automatically and to prod after approval; the same module version promoted through environments. → [Ch. 14](../14-workspaces-and-environments/README.md), [Ch. 21](../21-best-practices/README.md), [Project 09](../../projects/09-production-style-infrastructure/README.md)
</details>

<details>
<summary><strong>You need a database password. How do you avoid it ending up in state?</strong></summary>

Let AWS generate and store it (`manage_master_user_password = true` on RDS), or use an ephemeral resource + write-only argument (`password_wo`, `secret_string_wo`, Terraform 1.11+), or create only the secret container in Terraform and set the value out of band. Pass the secret's ARN to applications, not the value. → [Secrets Manager](../../aws-services/secrets-manager/README.md)
</details>

<details>
<summary><strong>A <code>count</code> depends on a value known only after apply. How do you fix it?</strong></summary>

Make the number/keys known at plan time: use a boolean input or a map with static keys and `for_each`, keeping computed values in the map values. `-target` can work around it once but isn't a fix. → [Ch. 22](../22-troubleshooting/README.md#invalid-count-or-for_each-argument)
</details>

## Official references

- [Terraform documentation](https://developer.hashicorp.com/terraform/docs)
- [HashiCorp Terraform Associate certification](https://developer.hashicorp.com/certifications/infrastructure-automation)

---

[← 22 · Troubleshooting](../22-troubleshooting/README.md) | [🏠 Home](../../README.md) | [📚 Learning Path](../00-learning-roadmap/README.md) | [Projects →](../../projects/README.md)
