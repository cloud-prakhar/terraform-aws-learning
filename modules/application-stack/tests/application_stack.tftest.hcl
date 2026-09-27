# Plan-only tests with a mocked AWS provider: nothing is created.
# Mocks apply to every nested module too.

mock_provider "aws" {
  mock_data "aws_availability_zones" {
    defaults = {
      names = ["us-east-1a", "us-east-1b", "us-east-1c"]
    }
  }

  mock_data "aws_iam_policy_document" {
    defaults = {
      json = "{\"Version\":\"2012-10-17\",\"Statement\":[]}"
    }
  }

  mock_data "aws_ami" {
    defaults = {
      id = "ami-0123456789abcdef0"
    }
  }
}

variables {
  name        = "shop"
  environment = "dev"
}

run "dev_defaults" {
  command = plan

  assert {
    condition     = length(module.app.instance_ids) == 1
    error_message = "Expected one instance by default."
  }

  # Values such as IDs are unknown during a plan, so plan-only tests
  # assert on things Terraform CAN know: counts, keys and inputs.
  assert {
    condition     = keys(module.app.instance_ids) == ["shop-dev-app-01"]
    error_message = "Instance names should follow <name>-<environment>-app-NN."
  }
}

run "warns_when_private_instances_have_no_nat" {
  command = plan

  variables {
    instance_subnet_tier = "private"
    enable_nat_gateway   = false
  }

  # check blocks only warn, but tests can still assert that they fired.
  expect_failures = [check.private_instances_have_egress]
}

run "rejects_bad_name" {
  command = plan

  variables {
    name = "Shop_App"
  }

  expect_failures = [var.name]
}
