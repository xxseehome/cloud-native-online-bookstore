variable "name_prefix" {
  type = string
}

variable "vpc_id" {
  type = string
}

variable "zone_mappings" {
  type = list(object({
    zone_id    = string
    vswitch_id = string
  }))
}

variable "tags" {
  type = map(string)
}
