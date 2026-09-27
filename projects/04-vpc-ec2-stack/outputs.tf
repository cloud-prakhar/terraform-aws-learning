output "website_url" {
  description = "Public URL (proxied to the private app server). Allow 1-2 minutes after apply."
  value       = "http://${aws_instance.web.public_ip}"
}

output "app_private_ip" {
  description = "Private IP of the app server: reachable only inside the VPC."
  value       = aws_instance.app.private_ip
}

output "subnets" {
  description = "Public and private subnet IDs."
  value = {
    public  = aws_subnet.public.id
    private = aws_subnet.private.id
  }
}
