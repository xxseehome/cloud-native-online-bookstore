variable "name_prefix" {
  type = string
}

variable "vswitch_id" {
  type = string
}

variable "ecs_instance_id" {
  type = string
}

variable "frontend_port" {
  type    = number
  default = 80
}

variable "backend_port" {
  type    = number
  default = 80
}

variable "health_check_uri" {
  type    = string
  default = "/health"
}

variable "tags" {
  type = map(string)
}
