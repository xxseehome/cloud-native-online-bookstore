output "vpc_id" {
  description = "Shared VPC ID."
  value       = module.network.vpc_id
}

output "vswitch_ids" {
  description = "vSwitch IDs ordered to match availability_zones."
  value       = module.network.vswitch_ids
}

output "security_group_id" {
  description = "Security group used by the K3s node."
  value       = module.network.security_group_id
}

output "ecs_instance_id" {
  description = "ECS instance ID for the single K3s node."
  value       = module.compute.instance_id
}

output "ecs_public_ip" {
  description = "Public IP used as the fallback entry point when no load balancer is enabled."
  value       = module.compute.public_ip
}

output "oss_bucket_name" {
  description = "Private OSS bucket used by the application."
  value       = module.storage.bucket_name
}

output "oss_intranet_endpoint" {
  description = "OSS endpoint used from ECS without public egress."
  value       = module.storage.intranet_endpoint
}

output "slb_id" {
  description = "SLB ID when enable_slb is true."
  value       = var.enable_slb ? module.slb[0].id : null
}

output "slb_address" {
  description = "Public SLB address when enable_slb is true."
  value       = var.enable_slb ? module.slb[0].address : null
}
