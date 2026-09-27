data "aws_ami" "al2023" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-2023.*-x86_64"]
  }
}

data "aws_availability_zones" "available" {
  state = "available"
}

data "aws_vpc" "default" {
  default = true
}

# Default subnets, one per AZ. We look up the subnet for each AZ we use.
data "aws_subnet" "by_az" {
  for_each = toset([for s in values(var.servers) : data.aws_availability_zones.available.names[s.az_index]])

  vpc_id            = data.aws_vpc.default.id
  availability_zone = each.key
  default_for_az    = true
}

locals {
  # Enrich each server with its AZ name so the instance and its volume
  # are guaranteed to land in the same AZ (EBS volumes are AZ-scoped).
  servers = {
    for name, s in var.servers : name => merge(s, {
      az = data.aws_availability_zones.available.names[s.az_index]
    })
  }
}

resource "aws_instance" "server" {
  for_each = local.servers

  ami                         = data.aws_ami.al2023.id
  instance_type               = each.value.instance_type
  subnet_id                   = data.aws_subnet.by_az[each.value.az].id
  associate_public_ip_address = false

  metadata_options {
    http_tokens = "required"
  }

  root_block_device {
    volume_type = "gp3"
    encrypted   = true
  }

  tags = {
    Name = each.key
  }
}

# A separate EBS volume outlives the instance if you want it to: data
# on it survives instance replacement. COST: EBS is billed per GB-month
# for as long as the volume exists, attached or not.
resource "aws_ebs_volume" "data" {
  for_each = local.servers

  availability_zone = each.value.az
  size              = each.value.data_volume_gb
  type              = "gp3"
  encrypted         = true

  tags = {
    Name = "${each.key}-data"
  }
}

resource "aws_volume_attachment" "data" {
  for_each = local.servers

  # Linux on Nitro instances exposes this as an NVMe device
  # (e.g. /dev/nvme1n1); /dev/sdf is the name used by the EC2 API.
  device_name = "/dev/sdf"
  volume_id   = aws_ebs_volume.data[each.key].id
  instance_id = aws_instance.server[each.key].id
}
