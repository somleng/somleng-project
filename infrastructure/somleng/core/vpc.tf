data "aws_availability_zones" "default_azs" {}
data "aws_availability_zones" "helium" {
  provider = aws.helium
}

module "vpc" {
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
  azs                          = data.aws_availability_zones.default_azs.names
}

module "vpc_helium" {
  source                       = "terraform-aws-modules/vpc/aws"
  name                         = "somleng"
  cidr                         = "10.20.0.0/22"
  public_subnets               = ["10.20.0.0/26", "10.20.0.64/26", "10.20.0.128/26"]
  private_subnets              = ["10.20.1.0/26", "10.20.1.64/26", "10.20.1.128/26"]
  database_subnets             = ["10.20.1.192/26", "10.20.2.0/26", "10.20.2.64/26"]
  intra_subnets                = ["10.20.2.128/26", "10.20.2.192/26", "10.20.3.0/26"]
  enable_dns_hostnames         = true
  enable_nat_gateway           = true
  single_nat_gateway           = true
  create_database_subnet_group = false
  azs                          = data.aws_availability_zones.helium.names

  providers = {
    aws = aws.helium
  }
}
