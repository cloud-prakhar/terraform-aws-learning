output "name_prefix" {
  description = "Interpolated name prefix."
  value       = local.name_prefix
}

output "instance_type" {
  description = "Instance type chosen by a conditional expression."
  value       = local.instance_type
}

output "public_server_names" {
  description = "Result of a filtered for expression."
  value       = local.public_server_names
}

output "disk_size_by_server" {
  description = "Map built with a for expression."
  value       = local.disk_size_by_server
}

output "subnet_cidrs" {
  description = "Subnet CIDRs calculated with cidrsubnet()."
  value       = local.subnet_cidrs
}

output "web_tags" {
  description = "Tags produced by merge()."
  value       = local.web_tags
}

output "summary" {
  description = "A few other expressions, grouped into one object."
  value = {
    max_retries            = local.max_retries
    instance_type_from_map = local.instance_type_from_map
    unique_ports           = local.unique_ports
    mixed_tuple            = local.mixed_tuple
    server_names           = local.server_names
    upper_server_names     = local.upper_server_names
    server_names_splat     = local.server_names_splat
    total_disk_gb          = local.total_disk_gb
    first_az               = local.first_az
    az_count               = local.az_count
    joined_azs             = local.joined_azs
    owner                  = local.owner
  }
}
