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

variable "admin_cidr" {
  type = string
}

variable "web_ingress_cidr" {
  type = string
}

variable "tags" {
  type = map(string)
}
