variable "alias" {}
variable "vpc_name" {}
variable "vpc_cidr_block" {}
variable "vpc_cidr_block_identifier" {}
variable "public_subnets" {
  default = null
}
variable "private_subnets" {
  default = null
}
variable "database_subnets" {
  default = null
}
variable "intra_subnets" {
  default = null
}

variable "logs_bucket_name" {}

variable "create_internal_load_balancer" {
  default = false
}

variable "create_public_load_balancer" {
  default = false
}

variable "create_nat_instance" {
  default = false
}

variable "internal_load_balancer_name" {
  default = null
}

variable "internal_load_balancer_security_group_name" {
  default = null
}

variable "ssl_certificate_domain_name" {
  default = null
}

variable "public_ssl_certificate_subject_alternative_names" {
  default = []
}

variable "internal_ssl_certificate_subject_alternative_names" {
  default = []
}

variable "public_load_balancer_name" {
  default = null
}

variable "public_load_balancer_security_group_name" {
  default = null
}

variable "route53_zone" {
  default = null
}
