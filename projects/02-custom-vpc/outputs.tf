output "vpc_id" {
  description = "ID of the VPC."
  value       = aws_vpc.this.id
}

output "subnet_ids_by_tier" {
  description = "Subnet IDs grouped by tier, ordered by AZ."
  value = {
    for tier in keys(local.tier_offsets) : tier => [
      for az in local.azs : aws_subnet.this["${tier}-${az}"].id
    ]
  }
}

output "subnet_cidrs" {
  description = "Planned CIDR of every subnet."
  value       = { for k, s in local.subnets : k => s.cidr }
}

output "nat_public_ips" {
  description = "Public IPs of the NAT gateways (empty when nat_gateway_mode = none)."
  value       = [for eip in aws_eip.nat : eip.public_ip]
}
