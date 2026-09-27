output "instance_id" {
  description = "ID of the instance."
  value       = aws_instance.this.id
}

output "ami" {
  description = "AMI used to launch the instance."
  value       = "${data.aws_ami.al2023.id} (${data.aws_ami.al2023.name})"
}

output "ssm_command" {
  description = "Open a shell on the instance (requires the Session Manager plugin)."
  value       = "aws ssm start-session --target ${aws_instance.this.id} --region ${var.aws_region}"
}
