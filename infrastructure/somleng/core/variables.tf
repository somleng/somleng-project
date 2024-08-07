variable "aws_default_region" {
  default = "ap-southeast-1"
}

variable "vpc_name" {
  default = "somleng"
}

variable "vpc_cidr" {
  default = "10.10.0.0/22"
}

variable "public_subnets" {
  default = ["10.10.0.0/26", "10.10.0.64/26", "10.10.0.128/26"]
}

variable "private_subnets" {
  default = ["10.10.1.0/26", "10.10.1.64/26", "10.10.1.128/26"]
}

variable "database_subnets" {
  default = ["10.10.1.192/26", "10.10.2.0/26", "10.10.2.64/26"]
}

variable "intra_subnets" {
  default = ["10.10.2.128/26", "10.10.2.192/26", "10.10.3.0/26"]
}

variable "enable_dns_hostnames" {
  default = true
}

variable "enable_nat_gateway" {
  default = true
}

variable "single_nat_gateway" {
  default = true
}

variable "create_database_subnet_group" {
  default = false
}
