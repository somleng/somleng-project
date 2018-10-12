module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = "${var.name}"
  cidr = "${var.cidr}"

  azs              = "${var.azs}"
  private_subnets  = "${var.private_subnets}"
  public_subnets   = "${var.public_subnets}"
  database_subnets = "${var.database_subnets}"
  intra_subnets    = "${var.intra_subnets}"

  enable_dns_hostnames = "${var.enable_dns_hostnames}"
  enable_dns_support   = "${var.enable_dns_support}"
  enable_nat_gateway   = true
  single_nat_gateway   = true
}
