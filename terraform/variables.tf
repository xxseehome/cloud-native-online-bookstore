variable "region" {
  description = "Alibaba Cloud region used by the shared demonstration stack."
  type        = string
  default     = "cn-hangzhou"
}

variable "project_name" {
  description = "Short project identifier used in resource names and tags."
  type        = string
  default     = "bookstore"

  validation {
    condition     = can(regex("^[a-z][a-z0-9-]{1,30}$", var.project_name))
    error_message = "project_name must start with a lowercase letter and contain only lowercase letters, numbers, and hyphens."
  }
}

variable "environment" {
  description = "Infrastructure environment. Application environments are Kubernetes namespaces in this shared stack."
  type        = string
  default     = "shared"
}

variable "availability_zones" {
  description = "Availability zones for vSwitches. Provide at least two zones when enable_alb is true."
  type        = list(string)
}

variable "vswitch_cidrs" {
  description = "CIDR blocks corresponding by index to availability_zones."
  type        = list(string)
  default     = ["10.20.1.0/24", "10.20.2.0/24"]
}

variable "vpc_cidr" {
  description = "CIDR block for the shared VPC."
  type        = string
  default     = "10.20.0.0/16"
}

variable "ssh_ingress_cidrs" {
  description = "Restricted IPv4 CIDRs allowed to reach SSH. Use Alibaba Cloud Workbench ranges or trusted administrator networks, never 0.0.0.0/0."
  type        = list(string)

  validation {
    condition = (
      length(var.ssh_ingress_cidrs) > 0 &&
      alltrue([
        for cidr in var.ssh_ingress_cidrs :
        cidr != "0.0.0.0/0" && can(cidrhost(cidr, 0))
      ])
    )
    error_message = "ssh_ingress_cidrs must contain valid restricted IPv4 CIDRs and cannot include 0.0.0.0/0."
  }
}

variable "k3s_api_ingress_cidrs" {
  description = "Restricted IPv4 CIDRs allowed to reach the K3s API. Keep empty when kubectl runs on the node."
  type        = list(string)
  default     = []

  validation {
    condition = alltrue([
      for cidr in var.k3s_api_ingress_cidrs :
      cidr != "0.0.0.0/0" && can(cidrhost(cidr, 0))
    ])
    error_message = "k3s_api_ingress_cidrs must contain only valid restricted IPv4 CIDRs and cannot include 0.0.0.0/0."
  }
}

variable "instance_type" {
  description = "ECS instance type selected from the active free-trial choices; 2 vCPU and 4 GiB is recommended."
  type        = string
}

variable "image_id" {
  description = "Ubuntu 22.04 LTS x86_64 image ID available in the selected region."
  type        = string
}

variable "ssh_public_key" {
  description = "OpenSSH public key imported into Alibaba Cloud. The private key must never enter Terraform state."
  type        = string
  sensitive   = true

  validation {
    condition     = can(regex("^(ssh-ed25519|ssh-rsa|ecdsa-sha2-nistp256) ", trimspace(var.ssh_public_key)))
    error_message = "ssh_public_key must be an OpenSSH public key."
  }
}

variable "internet_max_bandwidth_out" {
  description = "Maximum ECS public egress bandwidth in Mbit/s. Traffic charges and trial limits still apply."
  type        = number
  default     = 5

  validation {
    condition     = var.internet_max_bandwidth_out >= 1 && var.internet_max_bandwidth_out <= 100
    error_message = "internet_max_bandwidth_out must be between 1 and 100 Mbit/s for this demo."
  }
}

variable "system_disk_size" {
  description = "ECS system disk size in GiB."
  type        = number
  default     = 40

  validation {
    condition     = var.system_disk_size >= 40 && var.system_disk_size <= 80
    error_message = "system_disk_size must be between 40 and 80 GiB."
  }
}

variable "k3s_version" {
  description = "Pinned K3s release installed by cloud-init."
  type        = string
  default     = "v1.36.1+k3s1"
}

variable "oss_bucket_name" {
  description = "Globally unique OSS bucket name. Use the 20 GB local-redundancy free trial in the same region."
  type        = string

  validation {
    condition     = can(regex("^[a-z0-9][a-z0-9-]{1,61}[a-z0-9]$", var.oss_bucket_name))
    error_message = "oss_bucket_name must be 3-63 lowercase letters, numbers, or hyphens and cannot start or end with a hyphen."
  }
}

variable "enable_alb" {
  description = "Create/manage an ALB. False by default to prevent accidental paid resources before trial activation/import."
  type        = bool
  default     = false
}

variable "extra_tags" {
  description = "Additional tags applied to supported resources."
  type        = map(string)
  default     = {}
}
