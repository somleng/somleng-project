variable "alias" {}
variable "vpc_name" {}
variable "vpc_cidr_block" {}
variable "vpc_cidr_block_identifier" {}
variable "flow_logs_role" {}
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

variable "nat_instance_health_checker_image" {
  default = null
}

variable "nat_instance_iam_instance_profile" {
  default = null
}

variable "nat_instance_custom_routes" {
  default = {}
}

variable "create_s3_vpc_endpoint" {
  default = false
}
