output "vpc_id" {
  description = "The ID of the VPC"
  value       = "${module.vpc.vpc_id}"
}

output "database_subnet_group" {
  description = "ID of database subnet group"
  value       = "${module.vpc.database_subnet_group}"
}

output "private_subnets" {
  description = "List of IDs of private subnets"
  value       = "${module.vpc.private_subnets}"
}

output "public_subnets" {
  description = "List of IDs of public subnets"
  value       = "${module.vpc.public_subnets}"
}

output "database_subnets" {
  description = "List of database subnet ids"
  value       = "${module.vpc.database_subnets}"
}

output "intra_subnets" {
  description = "List of IDs of internal subnets"
  value       = "${module.vpc.intra_subnets}"
}
