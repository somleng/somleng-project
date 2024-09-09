variable "vpc" {}
variable "name" {
  default = "nat-instance"
}
variable "health_checker_name" {
  default = "nat-instance-health-checker"
}
