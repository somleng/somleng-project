locals {
  vpc_identifier        = "somleng"
  vpc_cidr_block        = "10.10.0.0/22"

  public_subnet_cidr_blocks = ["10.10.0.0/26", "10.10.0.64/26", "10.10.0.128/26"]

  private_subnet_cidr_blocks  = ["10.10.1.0/26", "10.10.1.64/26", "10.10.1.128/26"]
  database_subnet_cidr_blocks = ["10.10.1.192/26", "10.10.2.0/26", "10.10.2.64/26"]
  intra_subnet_cidr_blocks    = ["10.10.2.128/26", "10.10.2.192/26", "10.10.3.0/26"]
}

data "aws_availability_zones" "azs" {}

module "vpc" {
  source = "terraform-aws-modules/vpc/aws"
  name                 = local.vpc_identifier
  cidr                 = local.vpc_cidr_block
  private_subnets      = local.private_subnet_cidr_blocks
  database_subnets     = local.database_subnet_cidr_blocks
  intra_subnets        = local.intra_subnet_cidr_blocks
  public_subnets       = local.public_subnet_cidr_blocks
  enable_dns_hostnames = true
  enable_nat_gateway = true
  single_nat_gateway = true
  create_database_subnet_group = false
  azs              = data.aws_availability_zones.azs.names
}