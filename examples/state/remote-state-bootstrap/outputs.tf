output "state_bucket" {
  description = "Name of the state bucket. Put it in backend.hcl."
  value       = aws_s3_bucket.state.bucket
}

output "backend_hcl" {
  description = "Ready-to-use partial backend configuration."
  value       = <<-EOT
    bucket       = "${aws_s3_bucket.state.bucket}"
    region       = "${var.aws_region}"
    encrypt      = true
    use_lockfile = true
  EOT
}
