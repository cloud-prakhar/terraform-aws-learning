output "zone_id" {
  description = "ID of the private hosted zone."
  value       = aws_route53_zone.internal.zone_id
}

output "records" {
  description = "Fully qualified names created in the zone."
  value       = [aws_route53_record.db.fqdn, aws_route53_record.database_alias.fqdn]
}
