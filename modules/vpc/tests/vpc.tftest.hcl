# Plan-only tests with a mocked AWS provider: nothing is created.
#   cd modules/vpc && terraform init && terraform test

mock_provider "aws" {
  mock_data "aws_availability_zones" {
    defaults = {
      names = ["us-east-1a", "us-east-1b", "us-east-1c"]
    }
  }
}

variables {
  name = "test"
}

run "two_azs_by_default_without_nat" {
  command = plan

  assert {
    condition     = length(aws_subnet.public) == 2 && length(aws_subnet.private) == 2
    error_message = "Expected 2 public and 2 private subnets."
  }

  assert {
    condition     = length(aws_nat_gateway.this) == 0
    error_message = "NAT gateway must be opt-in because it costs money."
  }

  assert {
    condition     = aws_subnet.public["us-east-1a"].cidr_block == "10.0.0.0/24" && aws_subnet.private["us-east-1a"].cidr_block == "10.0.10.0/24"
    error_message = "Subnet CIDR plan changed unexpectedly."
  }
}

run "nat_gateway_when_enabled" {
  command = plan

  variables {
    enable_nat_gateway = true
    az_count           = 3
  }

  assert {
    condition     = length(aws_nat_gateway.this) == 1 && length(aws_subnet.private) == 3
    error_message = "Expected one NAT gateway and three private subnets."
  }
}

run "no_private_tier" {
  command = plan

  variables {
    create_private_subnets = false
    enable_nat_gateway     = true
  }

  assert {
    condition     = length(aws_subnet.private) == 0 && length(aws_nat_gateway.this) == 0
    error_message = "Without private subnets there is nothing for a NAT gateway to serve."
  }
}

run "rejects_bad_cidr" {
  command = plan

  variables {
    cidr_block = "10.0.0.0/33"
  }

  expect_failures = [var.cidr_block]
}
