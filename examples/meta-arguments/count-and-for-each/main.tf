data "aws_ami" "al2023" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-2023.*-x86_64"]
  }
}

# ---------------------------------------------------------------------
# count: N identical copies, addressed by number.
#   aws_instance.worker[0], aws_instance.worker[1], ...
# Good fit: the copies are interchangeable and only the number matters.
# ---------------------------------------------------------------------
resource "aws_instance" "worker" {
  count = var.instance_count

  ami                         = data.aws_ami.al2023.id
  instance_type               = "t3.micro"
  associate_public_ip_address = false

  metadata_options {
    http_tokens = "required"
  }

  root_block_device {
    encrypted = true
  }

  tags = {
    # count.index starts at 0; +1 gives friendlier names.
    Name = "worker-${count.index + 1}"
  }
}

# ---------------------------------------------------------------------
# for_each: one instance per map key, addressed by that key.
#   aws_s3_bucket.this["logs"], aws_s3_bucket.this["artifacts"], ...
# Good fit: each copy has an identity and possibly different settings.
# ---------------------------------------------------------------------
resource "aws_s3_bucket" "this" {
  for_each = var.buckets

  bucket_prefix = "tf-learning-${each.key}-"
  force_destroy = true

  tags = {
    Purpose = each.key
  }
}

# Chaining for_each: iterate over the buckets created above so every
# versioning resource is keyed exactly like its bucket.
resource "aws_s3_bucket_versioning" "this" {
  for_each = aws_s3_bucket.this

  bucket = each.value.id

  versioning_configuration {
    status = var.buckets[each.key].versioning ? "Enabled" : "Suspended"
  }
}
