# Plan-only tests with a mocked AWS provider: nothing is created.

mock_provider "aws" {
  mock_data "aws_ami" {
    defaults = {
      id = "ami-0123456789abcdef0"
    }
  }
}

variables {
  name       = "web"
  vpc_id     = "vpc-0123456789abcdef0"
  subnet_ids = ["subnet-aaaa", "subnet-bbbb"]
}

run "spreads_instances_across_subnets" {
  command = plan

  variables {
    instance_count = 3
  }

  assert {
    condition     = aws_instance.this["web-01"].subnet_id == "subnet-aaaa" && aws_instance.this["web-02"].subnet_id == "subnet-bbbb" && aws_instance.this["web-03"].subnet_id == "subnet-aaaa"
    error_message = "Instances should be spread round-robin across subnets."
  }

  assert {
    condition     = alltrue([for i in aws_instance.this : i.metadata_options[0].http_tokens == "required"])
    error_message = "All instances must require IMDSv2."
  }

  assert {
    condition     = alltrue([for i in aws_instance.this : i.root_block_device[0].encrypted])
    error_message = "Root volumes must be encrypted."
  }
}

run "explicit_ami_skips_lookup" {
  command = plan

  variables {
    ami_id = "ami-0fedcba9876543210"
  }

  assert {
    condition     = length(data.aws_ami.al2023) == 0 && aws_instance.this["web-01"].ami == "ami-0fedcba9876543210"
    error_message = "An explicit ami_id should be used as-is without an AMI lookup."
  }
}

run "rule_needs_exactly_one_source" {
  command = plan

  variables {
    ingress_rules = {
      bad = {
        description              = "both sources set"
        port                     = 80
        cidr_ipv4                = "0.0.0.0/0"
        source_security_group_id = "sg-0123456789abcdef0"
      }
    }
  }

  expect_failures = [var.ingress_rules]
}
