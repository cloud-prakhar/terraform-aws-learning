# COST: every hosted zone has a monthly charge (prorated only in the
# first 12 hours after creation), plus per-query charges.
# A PRIVATE zone is used so you do not need to own a domain name.

data "aws_vpc" "default" {
  default = true
}

resource "aws_route53_zone" "internal" {
  name    = var.zone_name
  comment = "tf-learning private zone"

  # Associating a VPC is what makes the zone private.
  vpc {
    vpc_id = data.aws_vpc.default.id
  }
}

# A record: name → IPv4 address. In a real stack this would point at a
# database or internal service rather than a fixed example address.
resource "aws_route53_record" "db" {
  zone_id = aws_route53_zone.internal.zone_id
  name    = "db.${var.zone_name}"
  type    = "A"
  ttl     = 300
  records = ["172.31.10.10"]
}

# CNAME: name → another name.
resource "aws_route53_record" "database_alias" {
  zone_id = aws_route53_zone.internal.zone_id
  name    = "database.${var.zone_name}"
  type    = "CNAME"
  ttl     = 300
  records = [aws_route53_record.db.fqdn]
}
