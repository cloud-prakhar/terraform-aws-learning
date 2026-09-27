[← 21 · Best Practices](../21-best-practices/README.md) | [🏠 Home](../../README.md) | [📚 Learning Path](../00-learning-roadmap/README.md) | [23 · Interview Preparation →](../23-interview-preparation/README.md)

# 22 · Troubleshooting

🟢🟡 Reference · Symptoms → likely reasons → how to investigate → how to fix

Start every investigation with the same three commands:

```bash
aws sts get-caller-identity      # WHO am I, in WHICH account?
terraform version                # WHICH Terraform and provider versions?
terraform workspace show         # WHICH state am I about to touch?
```

## Contents

| Area | Problems |
| --- | --- |
| Setup | [Provider authentication failure](#provider-authentication-failure) · [Wrong AWS Region](#wrong-aws-region) · [terraform init failure](#terraform-init-failure) · [Provider version mismatch](#provider-version-mismatch) |
| Configuration | [Missing variable](#missing-variable) · [Wrong variable type](#wrong-variable-type) · [Module path problem](#module-path-problem) · [Invalid count or for_each argument](#invalid-count-or-for_each-argument) · [Dependency issue](#dependency-issue) |
| AWS | [AccessDenied](#aws-accessdenied) · [Resource already exists](#resource-already-exists) · [Invalid AMI](#invalid-ami) · [Security group problems](#security-group-problems) |
| State | [State lock issue](#state-lock-issue) · [Backend initialization issue](#backend-initialization-issue) |
| CI/CD | [GitHub Actions AssumeRole / OIDC failure](#github-actions-assumerole--oidc-failure) |
| Tools | [Debug logging](#debug-logging) |

---

## Provider authentication failure

**Symptom:** `No valid credential sources found`, `failed to refresh cached credentials`, `ExpiredToken`, or `InvalidClientTokenId`.

**Likely reasons:** no credentials in the chain; `AWS_PROFILE` not set in this terminal; SSO session expired; stale `AWS_ACCESS_KEY_ID` environment variables overriding your profile.

**Investigate:**

```bash
aws sts get-caller-identity
env | grep '^AWS_'            # leftover variables take precedence over profiles
aws configure list            # which source the CLI is using
```

**Fix:** `aws sso login --profile <p>`; `export AWS_PROFILE=<p>`; `unset AWS_ACCESS_KEY_ID AWS_SECRET_ACCESS_KEY AWS_SESSION_TOKEN` if they are stale. See [Chapter 02](../02-installation-and-setup/README.md#3-configure-aws-credentials-safely).

## Wrong AWS Region

**Symptom:** "I applied, but I can't see anything in the console", or a data source finds nothing (`no matching EC2 VPC found`).

**Likely reasons:** the console shows a different Region than `var.aws_region`; `AWS_REGION` / `AWS_DEFAULT_REGION` differ from what you expect.

**Investigate:** `terraform output`, `terraform state show <resource>` (look at `arn`, which contains the Region), `echo $AWS_REGION`.

**Fix:** switch the console Region, or pass `-var aws_region=...`. Keep one Region for all labs.

## terraform init failure

**Symptom:** `Failed to query available provider packages`, `Could not retrieve the list of available versions`, checksum errors.

**Likely reasons:** no internet/proxy blocking `registry.terraform.io` or `releases.hashicorp.com`; typo in `source`; a lock file created on another platform without that platform's hashes.

**Investigate:** `terraform providers`; check `required_providers`; try `curl -I https://registry.terraform.io`.

**Fix:** correct the `source`; configure the proxy (`HTTPS_PROXY`); add platform hashes with `terraform providers lock -platform=linux_amd64 -platform=darwin_arm64 -platform=windows_amd64`.

## Provider version mismatch

**Symptom:** `locked provider ... does not match configured version constraint`, or `Unsupported argument` for an argument that exists in the docs.

**Likely reasons:** the lock file pins a version outside the new constraint; you are reading docs for a newer provider than you have installed (or vice versa).

**Investigate:** `terraform version` (shows provider versions); compare with the docs page version selector on the Registry.

**Fix:** `terraform init -upgrade`, review, commit the updated `.terraform.lock.hcl`. For a major upgrade, read the provider's upgrade guide first.

## Missing variable

**Symptom:** Terraform prompts `var.x Enter a value:`, or in CI: `No value for required variable`.

**Fix:** give it a value (tfvars, `-var`, `TF_VAR_x`) or a `default` if it should be optional. In CI, always use `-input=false` (`TF_INPUT=false`) so a missing value fails fast instead of hanging.

## Wrong variable type

**Symptom:** `Invalid value for input variable ... a number is required` / `string required`.

**Likely reasons:** quoting (`-var 'count="2"'`), a map passed as a string, `TF_VAR_` values for complex types not written in HCL syntax.

**Fix:** match the declared type. Complex values on the command line or in `TF_VAR_` use HCL syntax: `-var 'extra_tags={Owner="alice"}'`, `TF_VAR_subnets='["a","b"]'`.

## Module path problem

**Symptom:** `Module not installed`, `Unreadable module directory`, or `Module source has changed`.

**Likely reasons:** `terraform init` not re-run after adding/changing a `module` block; wrong relative path (paths are relative to the **calling** module's directory).

**Investigate:** `ls` the path from the calling directory; check `.terraform/modules/modules.json`.

**Fix:** correct the path, then `terraform init`.

## Invalid count or for_each argument

**Symptom:** `The "count" value depends on resource attributes that cannot be determined until apply` (or the same for `for_each`).

**Likely reason:** `count`/`for_each` keys use a value that is only known after apply — e.g. `count = var.policy_json == null ? 0 : 1` where `policy_json` contains an ARN of a resource created in the same run.

**Fix:** make keys static and move unknown values into the map's **values**: `for_each = { "read-artifacts" = data.aws_iam_policy_document.x.json }`. The course hit exactly this while building [modules/iam](../../modules/iam/README.md#design-notes-why-inline_policies-is-a-map). Using `-target` to apply the dependency first is a workaround, not a fix.

## Dependency issue

**Symptom:** intermittent `AccessDenied` or "not found" errors right after creation that disappear on a second `apply`; `Cycle` errors.

**Likely reasons:** a hidden dependency Terraform can't see (IAM propagation, a policy needed at boot); AWS eventual consistency; two resources referencing each other.

**Investigate:** `terraform graph` (look for the missing edge, or `-draw-cycles` with `-type=plan` for cycles).

**Fix:** add a reference, or `depends_on` for hidden dependencies ([Chapter 09](../09-meta-arguments/README.md#4-depends_on)). Break cycles by splitting a resource (e.g. separate `aws_vpc_security_group_ingress_rule` resources instead of inline rules that reference each other).

## AWS AccessDenied

**Symptom:** `AccessDenied` / `UnauthorizedOperation` / `is not authorized to perform: <action> on resource: <arn>`.

**Likely reasons:** the identity lacks the permission; an SCP or permissions boundary denies it; a resource policy (bucket, KMS key) denies it; a condition (Region, tags, MFA) doesn't match.

**Investigate:** the error names the **action** and **resource** — read it carefully; `aws sts get-caller-identity`; for encoded messages: `aws sts decode-authorization-message --encoded-message <msg>`; check CloudTrail for the denied call.

**Fix:** grant the specific action on the specific ARN. For KMS-encrypted resources, remember `kms:Decrypt`/`kms:GenerateDataKey` on the key.

## Resource already exists

**Symptom:** `BucketAlreadyExists`, `EntityAlreadyExists`, `InvalidGroup.Duplicate`, `ResourceAlreadyExistsException`.

**Likely reasons:** the object exists outside this state (created by hand, by another configuration, or by a crashed apply); a globally unique name (S3) is taken by someone else; a deleted secret still in its recovery window.

**Fix:** if it's yours and should be managed here → `import` block ([Chapter 15](../15-import-and-existing-resources/README.md)). If the name is taken globally → use `bucket_prefix`/another name. Secrets Manager: wait for the recovery window, or restore/force-delete the old secret.

## Invalid AMI

**Symptom:** `InvalidAMIID.NotFound` / `InvalidAMIID.Malformed`, or `The architecture 'arm64' of the specified instance type does not match the architecture 'x86_64' of the specified AMI`.

**Likely reasons:** a hard-coded AMI ID from another Region or deregistered; an ARM instance type (`t4g`) with an x86 AMI or vice versa.

**Fix:** look AMIs up with `data "aws_ami"` and pin `owners`; match the `architecture` filter to the instance family; add a `precondition` ([Chapter 09](../09-meta-arguments/README.md#6-lifecycle)).

## Security group problems

**Symptom:** timeouts connecting to an instance or database; `DependencyViolation` when deleting a security group; plan wants to replace a group attached to running instances.

**Investigate:** Is there an **ingress** rule on the target for your source (CIDR or source SG)? Does the source have an **egress** rule (Terraform removes the default)? Is the subnet public (route to IGW) and does the instance have a public IP? NACLs?

**Fix:** add the missing rule; use `name_prefix` + `create_before_destroy` on groups that get replaced; delete dependent resources (ENIs, instances) first on `DependencyViolation`. See [Security groups](../../aws-services/security-groups/README.md).

## State lock issue

**Symptom:** `Error acquiring the state lock` with lock info (ID, who, when).

**Likely reasons:** another run (a colleague, CI) is genuinely running; a previous run crashed and left the lock.

**Investigate:** the lock info's `Who` and `Created`; the CI run list; for S3: does `<key>.tflock` exist?

**Fix:** wait (`-lock-timeout=5m`). Only when you are **sure** nothing is running: `terraform force-unlock <LOCK_ID>`.

## Backend initialization issue

**Symptom:** `Backend initialization required, please run "terraform init"`, `Backend configuration changed`, `S3 bucket does not exist`, `AccessDenied` on the state object.

**Fix:** `terraform init` (with `-backend-config=...` if you use partial configuration). If the backend changed: `-migrate-state` to copy state, `-reconfigure` to switch without copying ([Chapter 12](../12-remote-state/README.md#5-migrating-state)). Check the bucket name/Region and that your identity has the permissions listed in Chapter 12.

## GitHub Actions AssumeRole / OIDC failure

**Symptom:** `Not authorized to perform sts:AssumeRoleWithWebIdentity`, `Could not assume role with OIDC`, or `Credentials could not be loaded`.

**Likely reasons (in order of frequency):**

1. The job's `sub` doesn't match the trust policy — e.g. the job has no `environment:` but the role trusts `…:environment:dev`, or the repository was renamed/forked.
2. Missing `permissions: id-token: write` in the workflow or job.
3. The OIDC provider doesn't exist in that account, or its audience isn't `sts.amazonaws.com`.
4. Wrong role ARN in the variable (dev role for a prod job).
5. Pull request from a fork (no OIDC token for the base repository's trust).

**Investigate:** print the claims the trust policy sees — temporarily add a step that decodes the token, or compare the job context (event, branch, environment) with the `sub` table in [Chapter 18](../18-github-actions/README.md#restricting-trust-the-sub-claim); check the role's trust policy in IAM; check CloudTrail for the `AssumeRoleWithWebIdentity` event and its error.

**Fix:** align the trust policy `sub` with the job context (or the job with the policy); add `id-token: write`.

## Debug logging

When the error message isn't enough:

```bash
TF_LOG=DEBUG terraform plan 2> debug.log     # TRACE, DEBUG, INFO, WARN, ERROR
TF_LOG_PROVIDER=DEBUG terraform apply        # provider (AWS API) logs only
TF_LOG_PATH=./tf.log TF_LOG=TRACE terraform plan
```

Search the log for the AWS API call (e.g. `CreateBucket`) and its HTTP response. Logs can contain secrets and tokens: never paste them publicly without redacting.

## Official references

- [Debugging Terraform](https://developer.hashicorp.com/terraform/internals/debugging)
- [AWS provider: authentication troubleshooting](https://registry.terraform.io/providers/hashicorp/aws/latest/docs#authentication-and-configuration)
- [Troubleshooting IAM (AWS)](https://docs.aws.amazon.com/IAM/latest/UserGuide/troubleshoot.html)
- [configure-aws-credentials: OIDC troubleshooting](https://github.com/aws-actions/configure-aws-credentials#oidc)

---

[← 21 · Best Practices](../21-best-practices/README.md) | [🏠 Home](../../README.md) | [📚 Learning Path](../00-learning-roadmap/README.md) | [23 · Interview Preparation →](../23-interview-preparation/README.md)
