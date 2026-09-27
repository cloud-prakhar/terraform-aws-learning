# Nothing here creates infrastructure. Locals are named expressions that
# you can inspect with `terraform console` (see the README for exercises).

locals {
  # --- Primitive types --------------------------------------------------
  project_name = "tf-learning" # string
  max_retries  = 3             # number
  is_prod      = var.environment == "prod"

  # String interpolation inserts a value into a string.
  name_prefix = "${local.project_name}-${var.environment}"

  # --- Conditional expression: condition ? value_if_true : value_if_false
  instance_type = local.is_prod ? "t3.medium" : "t3.micro"

  # Map lookup by key (same result as above, driven by data instead of logic).
  instance_type_from_map = var.instance_types[var.environment]

  # --- Collections -------------------------------------------------------
  # A set has no order and no duplicates.
  unique_ports = toset([80, 443, 443, 22])

  # A tuple is a fixed-length sequence whose elements may have different types.
  mixed_tuple = ["web", 2, true]

  # --- for expressions ---------------------------------------------------
  # [ for ... ] produces a list, { for ... } produces a map.
  server_names        = [for s in var.servers : s.name]
  upper_server_names  = [for s in var.servers : upper(s.name)]
  public_server_names = [for s in var.servers : s.name if s.public]
  disk_size_by_server = { for s in var.servers : s.name => s.size_gb }

  # --- Splat expression: a shorthand for [for s in var.servers : s.name]
  server_names_splat = var.servers[*].name

  # --- Functions ---------------------------------------------------------
  total_disk_gb = sum([for s in var.servers : s.size_gb])
  first_az      = element(var.availability_zones, 0)
  az_count      = length(var.availability_zones)
  joined_azs    = join(",", var.availability_zones)

  # cidrsubnet(prefix, newbits, netnum) carves smaller networks out of a
  # larger one. Chapter 10 and the VPC track use it to plan subnets.
  vpc_cidr     = "10.0.0.0/16"
  subnet_cidrs = [for i in range(3) : cidrsubnet(local.vpc_cidr, 8, i)]

  # merge() combines maps; later maps win on duplicate keys.
  common_tags = {
    Project     = local.project_name
    Environment = var.environment
  }
  web_tags = merge(local.common_tags, { Role = "web" })

  # null means "no value". coalesce() returns the first non-null argument.
  optional_owner = null
  owner          = coalesce(local.optional_owner, "platform-team")
}
