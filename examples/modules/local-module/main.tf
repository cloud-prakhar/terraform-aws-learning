# A module call is like a function call: source says WHERE the code is,
# the other arguments are the module's input variables.
module "logs_bucket" {
  source = "../../../modules/s3"

  bucket_prefix = "tf-learning-logs-"
  force_destroy = true
}

# Modules support for_each too: one module instance per map key.
#   module.bucket["reports"], module.bucket["scratch"]
module "bucket" {
  source   = "../../../modules/s3"
  for_each = var.buckets

  bucket_prefix      = "tf-learning-${each.key}-"
  versioning_enabled = each.value
  force_destroy      = true

  tags = {
    Purpose = each.key
  }
}
