resource "alicloud_ecs_key_pair" "this" {
  key_pair_name = "${var.name_prefix}-admin"
  public_key    = trimspace(var.ssh_public_key)
  tags          = var.tags
}

resource "alicloud_instance" "k3s" {
  instance_name              = "${var.name_prefix}-k3s"
  host_name                  = "${var.name_prefix}-k3s"
  image_id                   = var.image_id
  instance_type              = var.instance_type
  security_groups            = [var.security_group_id]
  vswitch_id                 = var.vswitch_id
  instance_charge_type       = "PostPaid"
  internet_charge_type       = "PayByTraffic"
  internet_max_bandwidth_out = var.internet_max_bandwidth_out
  system_disk_category       = var.system_disk_category
  system_disk_size           = var.system_disk_size
  stopped_mode               = "StopCharging"
  http_tokens                = "required"
  user_data = base64encode(templatefile("${path.module}/cloud-init.yaml.tftpl", {
    k3s_version = var.k3s_version
  }))
  tags = var.tags

  lifecycle {
    prevent_destroy = true
  }
}

resource "alicloud_ecs_key_pair_attachment" "this" {
  key_pair_name = alicloud_ecs_key_pair.this.key_pair_name
  instance_ids  = [alicloud_instance.k3s.id]
  force         = true
}
