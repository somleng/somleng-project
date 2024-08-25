variable "name" {}
variable "vpc" {}
variable "ssl_certificate" {}
variable "logs_bucket" {}
variable "internal" {
  default = false
}

variable "security_group_name" {
  default = null
}
