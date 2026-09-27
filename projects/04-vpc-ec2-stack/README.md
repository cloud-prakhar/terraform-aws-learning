[← Project 03 · EC2 Web Server](../03-web-server/README.md) | [🏠 Home](../../README.md) | [📚 Learning Path](../../docs/00-learning-roadmap/README.md) | [⬆ Projects](../README.md) | [Project 05 · Secure S3 with KMS →](../05-secure-s3/README.md)

# Project 04 · VPC + EC2 Stack

🟡 Intermediate · Do it after the [EC2 track](../../aws-services/ec2/README.md) · 💰 **Hourly**: two `t3.micro` + one public IPv4 address (no NAT gateway)

## Requirements

1. A custom VPC with one **public** and one **private** subnet.
2. An **app server** in the private subnet: no public IP, serves HTTP on port 8080, and must work **without internet access** (no NAT gateway).
3. A **web proxy** in the public subnet: nginx on port 80 forwarding to the app server's private IP.
4. Security groups chained by reference: internet → web :80; web → app :8080; nothing else inbound.
5. Admin access to the web server through SSM only. The app server needs no AWS permissions — so it gets **no** IAM role.
6. Output the public URL and the app server's private IP.

## Architecture

```mermaid
flowchart LR
    classDef user fill:#F3F4F6,color:#111,stroke:#6B7280
    classDef gw fill:#8B5CF6,color:#fff,stroke:#6D28D9,stroke-width:2px
    classDef pub fill:#10B981,color:#fff,stroke:#047857,stroke-width:2px
    classDef priv fill:#3B82F6,color:#fff,stroke:#1D4ED8,stroke-width:2px

    U["Browser"]:::user -->|":80"| IGW["IGW"]:::gw
    subgraph VPC["VPC 10.40.0.0/16"]
        subgraph PUB["public subnet 10.40.0.0/24"]
            WEB["web: nginx proxy<br/>sg-web"]:::pub
        end
        subgraph PRIV["private subnet 10.40.10.0/24 (no internet route)"]
            APP["app: python http.server :8080<br/>sg-app"]:::priv
        end
    end
    IGW --> WEB -->|":8080<br/>sg-web → sg-app"| APP
```

## Concepts used

| Concept | Where |
| --- | --- |
| Splitting a configuration into `network.tf`, `security.tf`, `compute.tf` | this folder |
| Referencing one instance's attribute in another's user data (implicit dependency) | `aws_instance.web.user_data` uses `aws_instance.app.private_ip` |
| Security group chaining with `referenced_security_group_id` | [security.tf](security.tf) |
| Private subnet using the VPC main route table | [network.tf](network.tf) |
| `systemd-run` in user data to keep a process running | [compute.tf](compute.tf) |
| Least privilege by **omitting** a role, with a documented Checkov exception | `aws_instance.app` |

## Reference solution

[network.tf](network.tf) · [security.tf](security.tf) · [compute.tf](compute.tf) · [variables.tf](variables.tf) · [outputs.tf](outputs.tf)

## Run it

```bash
terraform init
terraform apply
sleep 120
curl -s "$(terraform output -raw website_url)"     # "Hello from the PRIVATE app server"
```

## Verify isolation

```bash
aws ec2 describe-instances --filters "Name=tag:Name,Values=tf-learning-p04-app" \
  --query "Reservations[0].Instances[0].PublicIpAddress"      # null
```

From an SSM session on the web server: `curl -s http://<app_private_ip>:8080` works. From your laptop, the app server's private IP is unreachable.

## Cleanup

```bash
terraform destroy
```

## Extensions

- Add a second AZ and a load balancer → that is [Project 08](../08-highly-available-web/README.md).
- Add a NAT gateway (toggle) and an S3 gateway endpoint; compare costs.

---

[← Project 03 · EC2 Web Server](../03-web-server/README.md) | [🏠 Home](../../README.md) | [📚 Learning Path](../../docs/00-learning-roadmap/README.md) | [⬆ Projects](../README.md) | [Project 05 · Secure S3 with KMS →](../05-secure-s3/README.md)
