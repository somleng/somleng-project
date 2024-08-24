data "aws_availability_zones" "this" {}

locals {
  public_subnets   = var.public_subnets == null ? formatlist("%s.%s.0/26", var.vpc_cidr_block_identifier, range(1, length(data.aws_availability_zones.this.names) + 1)) : var.public_subnets
  private_subnets  = var.private_subnets == null ? formatlist("%s.%s.64/26", var.vpc_cidr_block_identifier, range(1, length(data.aws_availability_zones.this.names) + 1)) : var.private_subnets
  database_subnets = var.database_subnets == null ? formatlist("%s.%s.128/26", var.vpc_cidr_block_identifier, range(1, length(data.aws_availability_zones.this.names) + 1)) : var.database_subnets
  intra_subnets    = var.intra_subnets == null ? formatlist("%s.%s.192/26", var.vpc_cidr_block_identifier, range(1, length(data.aws_availability_zones.this.names) + 1)) : var.intra_subnets
}

module "vpc" {
  source                       = "terraform-aws-modules/vpc/aws"
  name                         = var.name
  cidr                         = var.vpc_cidr_block
  public_subnets               = local.public_subnets
  private_subnets              = local.private_subnets
  database_subnets             = local.database_subnets
  intra_subnets                = local.intra_subnets
  enable_dns_hostnames         = true
  enable_nat_gateway           = true
  single_nat_gateway           = true
  create_database_subnet_group = false
  azs                          = data.aws_availability_zones.this.names
}
