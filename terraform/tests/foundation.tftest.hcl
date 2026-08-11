mock_provider "alicloud" {}

variables {
  availability_zones   = ["cn-hangzhou-h", "cn-hangzhou-i"]
  vswitch_cidrs        = ["10.20.1.0/24", "10.20.2.0/24"]
  ssh_ingress_cidrs    = ["203.0.113.10/32"]
  instance_type        = "ecs.test.large"
  image_id             = "ubuntu-test-image"
  system_disk_category = "cloud_essd_entry"
  ssh_public_key       = format("ssh-%s %s bookstore-test", "ed25519", "placeholder-key-material")
  oss_bucket_name      = "bookstore-foundation-test"
}

run "cost_safe_defaults" {
  command = plan

  assert {
    condition     = output.slb_id == null
    error_message = "SLB must remain disabled by default until the free-trial instance is explicitly adopted."
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

run "ssh_rejects_public_cidr" {
  command = plan

  variables {
    ssh_ingress_cidrs = ["0.0.0.0/0"]
  }

  expect_failures = [var.ssh_ingress_cidrs]
}
