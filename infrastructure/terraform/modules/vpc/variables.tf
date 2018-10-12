variable "name" {
  description = "Name of the VPC"
}

variable "cidr" {
  description = "CIDR of the VPC"
}

variable "azs" {
  description = "Availability Zones in the VPC"
  type        = "list"
}

variable "private_subnets" {
  description = "Private Subnet CIDRs"
  type        = "list"
}

variable "public_subnets" {
  description = "Public Subnet CIDRs"
  type        = "list"
}

variable "intra_subnets" {
  description = "Internal Subnet CIDRs"
  type        = "list"
  default     = []
}

variable "database_subnets" {
  description = "Database Subnets"
  type        = "list"
  default     = []
}

variable "enable_dns_hostnames" {
  default = true
}

variable "enable_dns_support" {
  default = true
}
