# Plan-only tests with a mocked AWS provider: nothing is created.

mock_provider "aws" {
  mock_data "aws_iam_policy_document" {
    defaults = {
      json = "{\"Version\":\"2012-10-17\",\"Statement\":[]}"
    }
  }
}

variables {
  name             = "test-role"
  trusted_services = ["ec2.amazonaws.com"]
}

run "no_profile_by_default" {
  command = plan

  assert {
    condition     = length(aws_iam_instance_profile.this) == 0 && length(aws_iam_role_policy.inline) == 0
    error_message = "Instance profile and inline policy must be opt-in."
  }
}

run "profile_and_policies" {
  command = plan

  variables {
    create_instance_profile = true
    managed_policy_arns     = ["arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"]
    inline_policies = {
      "read-bucket" = "{\"Version\":\"2012-10-17\",\"Statement\":[]}"
    }
  }

  assert {
    condition     = length(aws_iam_instance_profile.this) == 1 && length(aws_iam_role_policy_attachment.managed) == 1 && length(aws_iam_role_policy.inline) == 1
    error_message = "Expected an instance profile, one managed attachment and one inline policy."
  }
}

run "rejects_non_service_principal" {
  command = plan

  variables {
    trusted_services = ["arn:aws:iam::111122223333:root"]
  }

  expect_failures = [var.trusted_services]
}
