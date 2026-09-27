output "instance_ids" {
  description = "Map of instance name => instance ID."
  value       = { for name, instance in aws_instance.this : name => instance.id }
}

output "private_ips" {
  description = "Map of instance name => private IPv4 address."
  value       = { for name, instance in aws_instance.this : name => instance.private_ip }
}

output "public_ips" {
  description = "Map of instance name => public IPv4 address (empty strings when none)."
  value       = { for name, instance in aws_instance.this : name => instance.public_ip }
}

output "security_group_id" {
  description = "ID of the instances' security group, e.g. to allow it as a source elsewhere."
  value       = aws_security_group.this.id
}
