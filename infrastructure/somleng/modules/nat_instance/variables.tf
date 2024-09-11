variable "vpc" {}
variable "flow_logs_role" {}
variable "identifier" {
  default = "nat-instance"
}
variable "health_checker_name" {
  default = null
}

variable "health_checker_image" {
  default = null
}

variable "custom_routes" {
  type    = map(string)
  default = {}
}
