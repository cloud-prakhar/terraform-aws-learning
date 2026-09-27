output "servers" {
  description = "Per-server instance ID, AZ and data volume ID."
  value = {
    for name, instance in aws_instance.server : name => {
      instance_id = instance.id
      az          = instance.availability_zone
      volume_id   = aws_ebs_volume.data[name].id
    }
  }
}
