variable "name" {
  description = "Name of the VPC"
  default     = "somleng"
}

variable "cidr" {
  description = "CIDR of the VPC"
  default     = "10.0.0.0/24"
}

variable "azs" {
  description = "Availability Zones in the VPC"
  default     = ["ap-southeast-1a", "ap-southeast-1b", "ap-southeast-1c"]
}

variable "private_subnets" {
  description = "Private Subnet CIDRs"
  default     = ["10.0.0.0/28", "10.0.0.16/28", "10.0.0.32/28"]
}

variable "public_subnets" {
  description = "Public Subnet CIDRs"
  default     = ["10.0.0.48/28", "10.0.0.64/28", "10.0.0.80/28"]
}

variable "database_subnets" {
  description = "Database Subnets"
  default     = ["10.0.0.96/28", "10.0.0.112/28", "10.0.0.128/28"]
}

variable "enable_dns_hostnames" {
  default = false
}
