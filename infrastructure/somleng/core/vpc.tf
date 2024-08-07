data "aws_availability_zones" "default_azs" {}
data "aws_availability_zones" "helium" {
  provider = aws.helium
}

module "vpc" {
  source                       = "terraform-aws-modules/vpc/aws"
  name                         = var.vpc_name
  cidr                         = var.vpc_cidr
  public_subnets               = var.public_subnets
  private_subnets              = var.private_subnets
  database_subnets             = var.database_subnets
  intra_subnets                = var.intra_subnets
  enable_dns_hostnames         = var.enable_dns_hostnames
  enable_nat_gateway           = var.enable_nat_gateway
  single_nat_gateway           = var.single_nat_gateway
  create_database_subnet_group = var.create_database_subnet_group
  azs                          = data.aws_availability_zones.default_azs.names
}

module "vpc_helium" {
  source                       = "terraform-aws-modules/vpc/aws"
  name                         = "somleng"
  cidr                         = "10.10.0.0/22"
  public_subnets               = ["10.10.0.0/26", "10.10.0.64/26", "10.10.0.128/26"]
  private_subnets              = ["10.10.1.0/26", "10.10.1.64/26", "10.10.1.128/26"]
  database_subnets             = ["10.10.1.192/26", "10.10.2.0/26", "10.10.2.64/26"]
  intra_subnets                = ["10.10.2.128/26", "10.10.2.192/26", "10.10.3.0/26"]
  enable_dns_hostnames         = true
  enable_nat_gateway           = true
  single_nat_gateway           = true
  create_database_subnet_group = false
  azs                          = data.aws_availability_zones.helium.names

  providers = {
    aws = aws.helium
  }
}
