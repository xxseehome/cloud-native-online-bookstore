resource "alicloud_alb_load_balancer" "this" {
  vpc_id                      = var.vpc_id
  load_balancer_name          = "${var.name_prefix}-alb"
  address_type                = "Internet"
  address_ip_version          = "IPv4"
  load_balancer_edition       = "Basic"
  deletion_protection_enabled = true
  tags                        = var.tags

  load_balancer_billing_config {
    pay_type = "PayAsYouGo"
  }

  dynamic "zone_mappings" {
    for_each = var.zone_mappings
    content {
      zone_id    = zone_mappings.value.zone_id
      vswitch_id = zone_mappings.value.vswitch_id
    }
  }

  lifecycle {
    prevent_destroy = true
  }
}
