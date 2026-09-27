output "instance_id" {
  description = "ID of the EC2 instance."
  value       = aws_instance.web.id
}

output "instance_private_ip" {
  description = "Private IPv4 address of the instance."
  value       = aws_instance.web.private_ip
}

output "ami_id" {
  description = "AMI chosen by the data source at plan time."
  value       = data.aws_ami.al2023.id
}

output "bucket_name" {
  description = "Name of the artifacts bucket."
  value       = aws_s3_bucket.artifacts.bucket
}

output "bucket_arn" {
  description = "ARN of the artifacts bucket, e.g. for use in IAM policies."
  value       = aws_s3_bucket.artifacts.arn
}

output "connection_hint" {
  description = "Composite output built from several attributes."
  value       = "Instance ${aws_instance.web.id} (${local.instance_name}) runs in ${aws_instance.web.availability_zone}."
}
