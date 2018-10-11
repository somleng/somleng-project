module "vpc" {
  source = "../modules/vpc"
  name   = "${local.vpc_name}"

  cidr             = "${local.vpc_cidr_block}"
  azs              = "${local.vpc_azs}"
  private_subnets  = "${local.vpc_private_subnet_cidr_blocks}"
  public_subnets   = "${local.vpc_public_subnet_cidr_blocks}"
  database_subnets = "${local.vpc_database_subnet_cidr_blocks}"
}
