data "aws_availability_zones" "default_azs" {}
data "aws_region" "hydrogen" {
  name = var.aws_default_region
}
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
  cidr                         = "10.20.0.0/20"
  public_subnets               = formatlist("10.20.%s.0/26", range(1, length(data.aws_availability_zones.helium.names) + 1))
  private_subnets              = formatlist("10.20.%s.64/26", range(1, length(data.aws_availability_zones.helium.names) + 1))
  database_subnets             = formatlist("10.20.%s.128/26", range(1, length(data.aws_availability_zones.helium.names) + 1))
  intra_subnets                = formatlist("10.20.%s.192/26", range(1, length(data.aws_availability_zones.helium.names) + 1))
  enable_dns_hostnames         = true
  enable_nat_gateway           = true
  single_nat_gateway           = true
  create_database_subnet_group = false
  azs                          = data.aws_availability_zones.helium.names

  providers = {
    aws = aws.helium
  }
}

resource "aws_vpc_peering_connection" "request_hydrogen_to_helium" {
  vpc_id      = module.vpc.vpc_id
  peer_vpc_id = module.vpc_helium.vpc_id
  peer_region = var.aws_helium_region

  tags = {
    Name = "Hydrogen <-> Helium"
  }
}

resource "aws_vpc_peering_connection_options" "request_hydrogen_to_helium" {
  vpc_peering_connection_id = aws_vpc_peering_connection.request_hydrogen_to_helium.id

  requester {
    allow_remote_vpc_dns_resolution = true
  }
}

resource "aws_vpc_peering_connection_accepter" "accept_hydrogen_from_helium" {
  vpc_peering_connection_id = aws_vpc_peering_connection.request_hydrogen_to_helium.id

  auto_accept = true
  tags = {
    Name = "Helium <-> Hydrogen"
  }
  provider = aws.helium
}

resource "aws_vpc_peering_connection_options" "accept_hydrogen_from_helium" {
  vpc_peering_connection_id = aws_vpc_peering_connection_accepter.accept_hydrogen_from_helium.id

  accepter {
    allow_remote_vpc_dns_resolution = true
  }

  provider = aws.helium
}
