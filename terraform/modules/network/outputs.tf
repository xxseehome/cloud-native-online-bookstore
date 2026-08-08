output "vpc_id" {
  value = alicloud_vpc.this.id
}

output "vswitch_ids" {
  value = alicloud_vswitch.this[*].id
}

output "security_group_id" {
  value = alicloud_security_group.k3s.id
}
