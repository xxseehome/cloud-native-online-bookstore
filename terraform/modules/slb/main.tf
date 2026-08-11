resource "alicloud_slb_load_balancer" "this" {
  load_balancer_name = "${var.name_prefix}-slb"
  address_type       = "internet"
  address_ip_version = "ipv4"
  payment_type       = "PayAsYouGo"
  vswitch_id         = var.vswitch_id
  tags               = var.tags

  lifecycle {
    prevent_destroy = true

    # The Alibaba Cloud free-trial flow creates the instance. Import that
    # instance before apply; trial-selected SKU and network fields are
    # intentionally not rewritten by Terraform.
    ignore_changes = [
      address_type,
      address_ip_version,
      bandwidth,
      internet_charge_type,
      load_balancer_name,
      load_balancer_spec,
      payment_type,
      vswitch_id,
    ]
  }
}

resource "alicloud_slb_server_group" "this" {
  load_balancer_id = alicloud_slb_load_balancer.this.id
  name             = "${var.name_prefix}-slb-backend"
}

resource "alicloud_slb_server_group_server_attachment" "ecs" {
  server_group_id = alicloud_slb_server_group.this.id
  server_id       = var.ecs_instance_id
  port            = var.backend_port
  type            = "ecs"
  weight          = 100
}

resource "alicloud_slb_listener" "http" {
  load_balancer_id          = alicloud_slb_load_balancer.this.id
  protocol                  = "http"
  frontend_port             = var.frontend_port
  backend_port              = var.backend_port
  server_group_id           = alicloud_slb_server_group.this.id
  scheduler                 = "wrr"
  health_check              = "on"
  health_check_uri          = var.health_check_uri
  health_check_connect_port = var.backend_port
  health_check_http_code    = "http_2xx"

  # The backend attachment must exist before the listener is bound to it.
  depends_on = [alicloud_slb_server_group_server_attachment.ecs]
}
