data "aws_availability_zones" "azs" {}

module "vpc" {
  source = "terraform-aws-modules/vpc/aws"
  version = "~> v1.0"

  name   = "somleng"

  cidr             = "10.0.0.0/24"
  intra_subnets    = ["10.0.0.112/28", "10.0.0.128/28", "10.0.0.144/28"]
  private_subnets  = ["10.0.0.0/28", "10.0.0.16/28", "10.0.0.32/28"]
  database_subnets = ["10.0.0.160/28", "10.0.0.176/28", "10.0.0.192/28"]
  public_subnets   = ["10.0.0.208/28", "10.0.0.224/28", "10.0.0.240/28"]

  enable_dns_hostnames = true
  enable_nat_gateway = true
  single_nat_gateway = true
  create_database_subnet_group = false
  azs              = "${data.aws_availability_zones.azs.names}"
}