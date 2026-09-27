output "url" {
  description = "Load balancer URL. Refresh a few times to see different instances answer."
  value       = "http://${aws_lb.web.dns_name}"
}

output "autoscaling_group_name" {
  description = "Name of the Auto Scaling group."
  value       = aws_autoscaling_group.web.name
}

output "private_subnet_ids" {
  description = "Private subnets the instances run in."
  value       = module.vpc.private_subnet_ids
}
