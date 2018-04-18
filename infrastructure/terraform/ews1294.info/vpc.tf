module "pin_vpc" {
  source = "../modules/vpc"
  name   = "${local.vpc_name}"

  # PIN specific options
  cidr                 = "10.0.0.0/16"
  enable_dns_hostnames = true
  private_subnets      = ["10.0.3.0/24", "10.0.1.0/24", "10.0.5.0/24"]
  public_subnets       = ["10.0.2.0/24", "10.0.0.0/24", "10.0.4.0/24"]
  database_subnets     = ["10.0.6.0/28", "10.0.6.16/28", "10.0.6.32/28"]
}
