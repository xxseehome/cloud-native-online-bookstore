check "vswitch_inputs" {
  assert {
    condition     = length(var.availability_zones) == length(var.vswitch_cidrs)
    error_message = "availability_zones and vswitch_cidrs must have the same number of entries."
  }
}

check "alb_requires_two_zones" {
  assert {
    condition     = !var.enable_alb || length(var.availability_zones) >= 2
    error_message = "ALB requires vSwitches in at least two availability zones."
  }
}

check "only_one_public_load_balancer" {
  assert {
    condition     = !(var.enable_alb && var.enable_slb)
    error_message = "enable_alb and enable_slb are mutually exclusive; select one public load balancer mode."
  }
}

module "network" {
  source = "./modules/network"

  name_prefix           = local.name_prefix
  vpc_cidr              = var.vpc_cidr
  availability_zones    = var.availability_zones
  vswitch_cidrs         = var.vswitch_cidrs
  ssh_ingress_cidrs     = var.ssh_ingress_cidrs
  k3s_api_ingress_cidrs = var.k3s_api_ingress_cidrs
  web_ingress_cidr      = var.enable_alb || var.enable_slb ? var.vpc_cidr : "0.0.0.0/0"
  tags                  = local.common_tags
}

module "compute" {
  source = "./modules/compute"

  name_prefix                = local.name_prefix
  vswitch_id                 = module.network.vswitch_ids[0]
  security_group_id          = module.network.security_group_id
  instance_type              = var.instance_type
  image_id                   = var.image_id
  ssh_public_key             = var.ssh_public_key
  internet_max_bandwidth_out = var.internet_max_bandwidth_out
  system_disk_category       = var.system_disk_category
  system_disk_size           = var.system_disk_size
  k3s_version                = var.k3s_version
  tags                       = local.common_tags
}

module "storage" {
  source = "./modules/storage"

  bucket_name = var.oss_bucket_name
  tags        = local.common_tags
}

module "alb" {
  count  = var.enable_alb ? 1 : 0
  source = "./modules/alb"

  name_prefix = local.name_prefix
  vpc_id      = module.network.vpc_id
  zone_mappings = [
    for index, zone_id in var.availability_zones : {
      zone_id    = zone_id
      vswitch_id = module.network.vswitch_ids[index]
    }
  ]
  tags = local.common_tags
}

module "slb" {
  count  = var.enable_slb ? 1 : 0
  source = "./modules/slb"

  name_prefix     = local.name_prefix
  vswitch_id      = module.network.vswitch_ids[0]
  ecs_instance_id = module.compute.instance_id
  tags            = local.common_tags
}
