resource "alicloud_vpc" "this" {
  vpc_name   = "${var.name_prefix}-vpc"
  cidr_block = var.vpc_cidr
  tags       = var.tags
}

resource "alicloud_vswitch" "this" {
  count = length(var.availability_zones)

  vswitch_name = "${var.name_prefix}-vsw-${count.index + 1}"
  vpc_id       = alicloud_vpc.this.id
  zone_id      = var.availability_zones[count.index]
  cidr_block   = var.vswitch_cidrs[count.index]
  tags         = var.tags
}

resource "alicloud_security_group" "k3s" {
  security_group_name = "${var.name_prefix}-k3s-sg"
  description         = "Least-privilege ingress for the Online Book Store K3s node"
  vpc_id              = alicloud_vpc.this.id
  inner_access_policy = "Drop"
  tags                = var.tags
}

resource "alicloud_security_group_rule" "ssh" {
  for_each = toset(var.ssh_ingress_cidrs)

  type              = "ingress"
  ip_protocol       = "tcp"
  nic_type          = "intranet"
  policy            = "accept"
  port_range        = "22/22"
  priority          = 1
  security_group_id = alicloud_security_group.k3s.id
  cidr_ip           = each.value
}

resource "alicloud_security_group_rule" "k3s_api" {
  for_each = toset(var.k3s_api_ingress_cidrs)

  type              = "ingress"
  ip_protocol       = "tcp"
  nic_type          = "intranet"
  policy            = "accept"
  port_range        = "6443/6443"
  priority          = 1
  security_group_id = alicloud_security_group.k3s.id
  cidr_ip           = each.value
}

resource "alicloud_security_group_rule" "http" {
  type              = "ingress"
  ip_protocol       = "tcp"
  nic_type          = "intranet"
  policy            = "accept"
  port_range        = "80/80"
  priority          = 10
  security_group_id = alicloud_security_group.k3s.id
  cidr_ip           = var.web_ingress_cidr
}

resource "alicloud_security_group_rule" "https" {
  type              = "ingress"
  ip_protocol       = "tcp"
  nic_type          = "intranet"
  policy            = "accept"
  port_range        = "443/443"
  priority          = 10
  security_group_id = alicloud_security_group.k3s.id
  cidr_ip           = var.web_ingress_cidr
}
