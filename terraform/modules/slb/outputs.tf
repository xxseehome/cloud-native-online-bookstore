output "id" {
  value = alicloud_slb_load_balancer.this.id
}

output "address" {
  value = alicloud_slb_load_balancer.this.address
}

output "server_group_id" {
  value = alicloud_slb_server_group.this.id
}

output "listener_id" {
  value = alicloud_slb_listener.http.id
}
