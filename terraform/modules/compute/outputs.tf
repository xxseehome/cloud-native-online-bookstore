output "instance_id" {
  value = alicloud_instance.k3s.id
}

output "public_ip" {
  value = alicloud_instance.k3s.public_ip
}

output "private_ip" {
  value = alicloud_instance.k3s.private_ip
}

output "key_pair_name" {
  value = alicloud_ecs_key_pair.this.key_pair_name
}
