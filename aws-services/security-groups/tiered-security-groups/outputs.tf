output "security_group_ids" {
  description = "IDs of the three tiers' security groups."
  value = {
    alb = aws_security_group.alb.id
    app = aws_security_group.app.id
    db  = aws_security_group.db.id
  }
}
