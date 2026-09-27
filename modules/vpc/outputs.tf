output "vpc_id" {
  description = "ID of the VPC."
  value       = aws_vpc.this.id
}

output "vpc_cidr_block" {
  description = "CIDR block of the VPC."
  value       = aws_vpc.this.cidr_block
}

output "azs" {
  description = "Availability Zones used, in order."
  value       = local.azs
}

output "public_subnet_ids" {
  description = "Public subnet IDs, ordered like azs."
  value       = [for az in local.azs : aws_subnet.public[az].id]
}

output "private_subnet_ids" {
  description = "Private subnet IDs, ordered like azs (empty if disabled)."
  value       = [for az in local.azs : aws_subnet.private[az].id if var.create_private_subnets]
}

output "nat_gateway_public_ip" {
  description = "Public IP used by private subnets for outbound traffic, or null."
  value       = one(aws_eip.nat[*].public_ip)
}
