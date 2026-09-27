#!/bin/bash
# Runs once on first boot. Output goes to /var/log/cloud-init-output.log
set -euo pipefail
dnf update -y --security
echo "Provisioned by Terraform at $(date -u)" > /etc/motd
