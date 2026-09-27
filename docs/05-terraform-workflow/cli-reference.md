[← 05 · Terraform Workflow](README.md) | [🏠 Home](../../README.md) | [📚 Learning Path](../00-learning-roadmap/README.md) | [06 · The AWS Provider →](../06-aws-provider/README.md)

# 05b · Terraform CLI Reference

🟢🟡 Reference page · Read it once now, come back whenever you need a command.

Every command below lists **what it does**, **when to use it**, **important options**, an **example**, and a **common mistake**. Run `terraform <command> -help` for the full list of options in your installed version.

**Global option worth knowing:** `terraform -chdir=path/to/config <command>` runs a command in another directory without `cd`.

| Group | Commands |
| --- | --- |
| Everyday workflow | [version](#terraform-version) · [init](#terraform-init) · [fmt](#terraform-fmt) · [validate](#terraform-validate) · [plan](#terraform-plan) · [apply](#terraform-apply) · [destroy](#terraform-destroy) |
| Inspecting | [show](#terraform-show) · [output](#terraform-output) · [console](#terraform-console) · [providers](#terraform-providers) · [graph](#terraform-graph) |
| State | [state list](#terraform-state-list) · [state show](#terraform-state-show) · [state mv](#terraform-state-mv) · [state rm](#terraform-state-rm) · [import](#terraform-import) · [force-unlock](#terraform-force-unlock) |
| Environments and tests | [workspace](#terraform-workspace) · [test](#terraform-test) |
| Legacy | [refresh, taint](#legacy-commands) |

---

## terraform version

- **Does:** prints the Terraform version, the platform, and the versions of installed providers in the current directory.
- **Use when:** checking you meet a `required_version`, or reporting a bug.
- **Options:** `-json`.
- **Example:** `terraform version`
- **Common mistake:** debugging a "works on my machine" issue without comparing versions first.

## terraform init

- **Does:** configures the backend, downloads modules and providers, writes `.terraform.lock.hcl`. Details in [Chapter 05](README.md#1-terraform-init).
- **Use when:** first time in a directory; after adding/changing providers, modules or the backend.
- **Options:**
  - `-upgrade` — pick the newest provider/module versions allowed by constraints (updates the lock file).
  - `-backend=false` — skip backend setup (used for validation in CI).
  - `-backend-config=FILE_OR_KEY=VALUE` — supply backend settings at init time ([Chapter 12](../12-remote-state/README.md)).
  - `-migrate-state` — copy existing state to a newly configured backend.
  - `-reconfigure` — use the new backend configuration *without* migrating state.
- **Example:** `terraform init -backend-config=backend.hcl`
- **Common mistake:** forgetting to re-run `init` after adding a module or provider, which causes "Module not installed" or "Missing required provider" errors.

## terraform fmt

- **Does:** rewrites files into canonical formatting.
- **Use when:** before every commit (pre-commit can do it for you — [Chapter 17](../17-terraform-tooling/README.md)).
- **Options:** `-recursive`, `-check` (non-zero exit code if changes are needed), `-diff`.
- **Example:** `terraform fmt -recursive`
- **Common mistake:** running it only in the current directory and missing module subdirectories.

## terraform validate

- **Does:** checks syntax, references and types against provider schemas, without calling AWS.
- **Use when:** after edits, and in CI.
- **Options:** `-json`.
- **Example:** `terraform init -backend=false && terraform validate`
- **Common mistake:** assuming "valid" means "will apply successfully". Validation cannot know if an AMI exists or a name is taken.

## terraform plan

- **Does:** refreshes state from AWS, compares with configuration, shows proposed actions. Changes nothing.
- **Use when:** before every apply; in pull requests.
- **Options:**
  - `-out=tfplan` — save the plan for an exact apply later.
  - `-var 'name=value'`, `-var-file=file.tfvars` — set variables ([Chapter 07](../07-variables-and-outputs/README.md)).
  - `-destroy` — preview a destroy.
  - `-refresh-only` — only show drift; propose to update state, not infrastructure.
  - `-replace=ADDRESS` — force one resource to be replaced (replaces the old `taint`).
  - `-target=ADDRESS` — plan only part of the configuration. **Exceptional use only** (recovering from errors); routine use leaves the rest of the configuration unchecked.
  - `-detailed-exitcode` — exit code 0 = no changes, 1 = error, 2 = changes present (useful in scripts).
  - `-generate-config-out=file.tf` — *(experimental)* write configuration for resources in `import` blocks ([Chapter 15](../15-import-and-existing-resources/README.md)).
- **Example:** `terraform plan -var-file=prod.tfvars -out=tfplan`
- **Common mistake:** skimming past the summary line; not noticing a `-/+` replacement of a database.

## terraform apply

- **Does:** executes a plan and records results in state.
- **Use when:** you have reviewed the plan.
- **Options:** `-auto-approve` (no prompt), a saved plan file as argument, `-replace=ADDRESS`, `-parallelism=n` (default 10), `-lock-timeout=5m`.
- **Example:** `terraform apply tfplan`
- **Common mistake:** using `-auto-approve` interactively. If you did not read the plan, you do not know what you just did.

## terraform destroy

- **Does:** plans and executes deletion of everything in this configuration's state. Same as `terraform apply -destroy`.
- **Use when:** tearing down a lab or a temporary environment.
- **Options:** `-auto-approve`, `-target=ADDRESS` (exceptional use).
- **Example:** `terraform plan -destroy` (preview), then `terraform destroy`
- **Common mistake:** running it in the wrong directory or workspace. Check `terraform workspace show` and the plan's resource list first.

## terraform show

- **Does:** prints the current state, or a saved plan, in human-readable (or JSON) form.
- **Use when:** reviewing what exists, or reviewing a saved plan in CI.
- **Options:** `-json`, `-no-color`.
- **Example:** `terraform show tfplan`
- **Common mistake:** pasting `terraform show` output into tickets or chats. State can contain secrets.

## terraform output

- **Does:** prints root-module output values from state.
- **Use when:** scripts need a value (`-raw`), or a human wants the results.
- **Options:** `-raw NAME` (plain string, no quotes), `-json`.
- **Example:** `aws s3 ls "s3://$(terraform output -raw bucket_name)"`
- **Common mistake:** expecting `sensitive` outputs to be hidden from `-json` / `-raw`. They are printed in clear text there.

## terraform console

- **Does:** interactive prompt to evaluate expressions against your configuration and state.
- **Use when:** learning functions, debugging `for` expressions, inspecting values.
- **Options:** `-var`, `-var-file`; `-scope=MODULE_ADDRESS` (Terraform 1.16+) to evaluate inside a module.
- **Example:** `echo 'cidrsubnet("10.0.0.0/16", 8, 2)' | terraform console`
- **Common mistake:** expecting it to create anything. It is read-only.

## terraform providers

- **Does:** lists the providers required by the configuration and its modules, with version constraints.
- **Use when:** debugging "which module needs which provider?"
- **Subcommands:** `terraform providers lock -platform=linux_amd64 -platform=darwin_arm64` — add checksums for other platforms to the lock file (useful when CI and laptops differ).
- **Example:** `terraform providers`
- **Common mistake:** a lock file generated only on macOS failing in Linux CI — use `providers lock` with all platforms your team uses.

## terraform graph

- **Does:** prints the dependency graph in DOT format (for Graphviz).
- **Use when:** understanding or debugging ordering and cycle errors.
- **Options:** `-type=plan|plan-destroy|apply`, `-draw-cycles`.
- **Example:** `terraform graph | dot -Tsvg > graph.svg` (requires [Graphviz](https://graphviz.org/))
- **Common mistake:** trying to read the full `-type=plan` graph of a large configuration. Start with the default summary.

## terraform state list

- **Does:** lists every resource address in state.
- **Example:** `terraform state list` or `terraform state list 'aws_subnet.public'`
- **Common mistake:** forgetting quotes around addresses with brackets in some shells: `'aws_s3_bucket.this["logs"]'`.

## terraform state show

- **Does:** shows all recorded attributes of one resource.
- **Options:** `-json` (Terraform 1.16+).
- **Example:** `terraform state show 'aws_instance.web'`
- **Common mistake:** treating it as live data. It shows the last recorded state; run `terraform plan -refresh-only` to compare with AWS.

## terraform state mv

- **Does:** changes the address of a resource in state (rename, move into a module) without touching AWS.
- **Use when:** one-off refactoring. **Prefer a `moved` block** in code, which is reviewed, repeatable and works for everyone who shares the state ([Chapter 11](../11-terraform-state/README.md#6-refactoring-moved-and-removed-blocks)).
- **Example:** `terraform state mv aws_sqs_queue.orders aws_sqs_queue.order_events`
- **Common mistake:** running it on shared state without telling the team.

## terraform state rm

- **Does:** makes Terraform *forget* a resource. The object keeps running in AWS.
- **Use when:** handing a resource over to another configuration. **Prefer a `removed` block** in code ([Chapter 11](../11-terraform-state/README.md#6-refactoring-moved-and-removed-blocks)).
- **Example:** `terraform state rm aws_s3_bucket.legacy`
- **Common mistake:** thinking it deletes the resource. It does not; it becomes unmanaged.

## terraform import

- **Does:** records an existing AWS object at a resource address in state.
- **Use when:** you must adopt something created outside Terraform. **Prefer the `import` block**, which is planned and reviewed like any other change ([Chapter 15](../15-import-and-existing-resources/README.md)).
- **Example:** `terraform import aws_s3_bucket.legacy my-existing-bucket`
- **Common mistake:** importing without writing matching configuration; the next plan then wants to change or replace the resource.

## terraform force-unlock

- **Does:** removes a stuck state lock, given the lock ID printed in the error message.
- **Use when:** a run crashed or was killed and left a lock behind, **and you are sure nothing else is running**.
- **Example:** `terraform force-unlock 6a3e2b1c-...`
- **Common mistake:** unlocking while a colleague's or CI's apply is still running, leading to concurrent writes and a corrupted state.

## terraform workspace

- **Does:** manages multiple states for one configuration ([Chapter 14](../14-workspaces-and-environments/README.md)).
- **Subcommands:** `list`, `show`, `new NAME`, `select NAME`, `delete NAME`.
- **Example:** `terraform workspace new dev && terraform workspace select dev`
- **Common mistake:** forgetting which workspace is selected before `apply` or `destroy`.

## terraform test

- **Does:** runs `*.tftest.hcl` files ([Chapter 16](../16-testing-and-validation/README.md)).
- **Options:** `-filter=tests/file.tftest.hcl`, `-verbose`, `-junit-xml=report.xml`, `-var`.
- **Example:** `terraform test -verbose`
- **Common mistake:** forgetting that `run` blocks with `command = apply` (the default) **create real resources** (and then destroy them).

## Legacy commands

| Legacy | Use instead | Why |
| --- | --- | --- |
| `terraform refresh` | `terraform plan -refresh-only` then `terraform apply -refresh-only` | The legacy command updates state without showing you what changes. |
| `terraform taint ADDRESS` | `terraform apply -replace=ADDRESS` | `-replace` shows the effect in a plan before doing it. |
| `terraform untaint ADDRESS` | — | Only needed if you used `taint`. |

Both legacy commands still exist but are deprecated by HashiCorp.

---

## Debug logging

When an error message is not enough, enable Terraform's logs for one command:

```bash
TF_LOG=DEBUG terraform plan 2> debug.log     # levels: TRACE, DEBUG, INFO, WARN, ERROR
TF_LOG_PROVIDER=DEBUG terraform plan         # only provider logs (AWS API calls)
```

Logs are very verbose and **may contain secrets**; don't share them unredacted. See [Troubleshooting](../22-troubleshooting/README.md).

## Official references

- [Terraform CLI documentation](https://developer.hashicorp.com/terraform/cli)
- [Command reference index](https://developer.hashicorp.com/terraform/cli/commands)
- [Debugging Terraform](https://developer.hashicorp.com/terraform/internals/debugging)

---

[← 05 · Terraform Workflow](README.md) | [🏠 Home](../../README.md) | [📚 Learning Path](../00-learning-roadmap/README.md) | [06 · The AWS Provider →](../06-aws-provider/README.md)
