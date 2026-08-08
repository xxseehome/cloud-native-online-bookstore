variable "name_prefix" {
  type = string
}

variable "vswitch_id" {
  type = string
}

variable "security_group_id" {
  type = string
}

variable "instance_type" {
  type = string
}

variable "image_id" {
  type = string
}

variable "ssh_public_key" {
  type      = string
  sensitive = true
}

variable "internet_max_bandwidth_out" {
  type = number
}

variable "system_disk_size" {
  type = number
}

variable "k3s_version" {
  type = string
}

variable "tags" {
  type = map(string)
}
