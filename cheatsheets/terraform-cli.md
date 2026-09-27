[⬆ Terraform on AWS](../README.md) | [🏠 Home](../README.md) | [📚 Learning Path](../docs/00-learning-roadmap/README.md)

# Cheatsheet · Terraform CLI

Full explanations: [CLI reference](../docs/05-terraform-workflow/cli-reference.md)

## Everyday workflow

```bash
terraform init                          # backend, modules, providers, lock file
terraform init -upgrade                 # newer providers within constraints
terraform fmt -recursive                # format
terraform validate                      # syntax, types, references
terraform plan                          # preview
terraform plan -out=tfplan              # save the plan
terraform apply tfplan                  # apply exactly that plan
terraform apply                         # plan + prompt + apply
terraform destroy                       # delete everything in this state
terraform plan -destroy                 # preview a destroy
```

## Variables

```bash
terraform plan -var 'instance_type=t3.small'
terraform plan -var-file=prod.tfvars
export TF_VAR_instance_type=t3.small
```

## Inspect

```bash
terraform output                        # all outputs
terraform output -raw bucket_name       # one, unquoted
terraform output -json
terraform show                          # current state
terraform show tfplan                   # saved plan
terraform console                       # evaluate expressions
terraform providers                     # required providers
terraform graph | dot -Tsvg > g.svg     # dependency graph (needs Graphviz)
terraform version
```

## Targeted operations (use sparingly)

```bash
terraform plan -refresh-only            # show drift only
terraform apply -refresh-only           # accept drift into state
terraform apply -replace='aws_instance.web'    # force replacement (replaces taint)
terraform plan -target='module.vpc'     # exceptional: partial plan
```

## State

```bash
terraform state list
terraform state show 'aws_s3_bucket.this["logs"]'
terraform state mv  A B                 # prefer a moved block
terraform state rm  ADDRESS             # prefer a removed block
terraform import    ADDRESS ID          # prefer an import block
terraform state pull > backup.json
terraform force-unlock LOCK_ID          # only if nothing is running
```

## Backends

```bash
terraform init -backend-config=backend.hcl
terraform init -backend-config="bucket=my-state" -backend-config="region=us-east-1"
terraform init -migrate-state           # copy state to a new backend
terraform init -reconfigure             # switch backend without copying
terraform init -backend=false           # CI validation
```

## Workspaces

```bash
terraform workspace list | show | new NAME | select NAME | delete NAME
```

## Tests

```bash
terraform test
terraform test -verbose
terraform test -filter=tests/unit.tftest.hcl
```

## Automation-friendly settings

```bash
export TF_IN_AUTOMATION=true   # less "next step" chatter in output
export TF_INPUT=false          # never prompt; fail instead
terraform -chdir=path/to/config plan
terraform plan -detailed-exitcode   # 0 = no changes, 1 = error, 2 = changes
TF_LOG=DEBUG terraform plan 2> debug.log
```

---

[⬆ Terraform on AWS](../README.md) | [🏠 Home](../README.md) | [📚 Learning Path](../docs/00-learning-roadmap/README.md)
