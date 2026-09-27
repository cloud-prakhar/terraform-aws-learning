output "website_url" {
  description = "Open this in a browser 1-2 minutes after apply (nginx installs at boot)."
  value       = "http://${aws_instance.web.public_dns}"
}

output "instance_id" {
  description = "Instance ID, e.g. for `aws ssm start-session --target`."
  value       = aws_instance.web.id
}

output "public_ip" {
  description = "Public IPv4 address of the web server."
  value       = aws_instance.web.public_ip
}
