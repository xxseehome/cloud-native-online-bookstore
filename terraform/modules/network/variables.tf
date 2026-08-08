variable "name_prefix" {
  type = string
}

variable "vpc_cidr" {
  type = string
}

variable "availability_zones" {
  type = list(string)
}

variable "vswitch_cidrs" {
  type = list(string)
}

variable "ssh_ingress_cidrs" {
  type = list(string)
}

variable "k3s_api_ingress_cidrs" {
  type = list(string)
}

variable "web_ingress_cidr" {
  type = string
}

variable "tags" {
  type = map(string)
}
