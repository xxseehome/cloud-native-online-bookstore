mock_provider "alicloud" {}

variables {
  availability_zones = ["cn-hongkong-b", "cn-hongkong-c"]
  vswitch_cidrs      = ["10.20.1.0/24", "10.20.2.0/24"]
  admin_cidr         = "203.0.113.10/32"
  instance_type      = "ecs.test.large"
  image_id           = "ubuntu-test-image"
  ssh_public_key     = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAITestOnlyPublicKey bookstore-test"
  oss_bucket_name    = "bookstore-foundation-test"
}

run "cost_safe_defaults" {
  command = plan

  assert {
    condition     = output.alb_id == null
    error_message = "ALB must remain disabled by default to prevent an accidental paid resource."
  }

  assert {
    condition     = length(output.vswitch_ids) == 2
    error_message = "The network module must create one vSwitch for each supplied availability zone."
  }

  assert {
    condition     = output.oss_bucket_name == "bookstore-foundation-test"
    error_message = "The storage module must preserve the requested globally unique bucket name."
  }
}

run "alb_rejects_one_zone" {
  command = plan

  variables {
    enable_alb         = true
    availability_zones = ["cn-hongkong-b"]
    vswitch_cidrs      = ["10.20.1.0/24"]
  }

  expect_failures = [check.alb_requires_two_zones]
}
