variable "name" {}
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
