output "vpc_id" {
  description = "ID of the VPC."
  value       = aws_vpc.main.id
}

output "public_subnets" {
  description = "Map of AZ => public subnet ID."
  value       = { for az, s in aws_subnet.public : az => s.id }
}

output "private_subnets" {
  description = "Map of AZ => private subnet ID."
  value       = { for az, s in aws_subnet.private : az => s.id }
}
