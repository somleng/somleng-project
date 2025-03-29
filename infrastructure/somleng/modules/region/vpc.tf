data "aws_availability_zones" "this" {}

locals {
  public_subnets   = var.public_subnets == null ? formatlist("%s.%s.0/26", var.vpc_cidr_block_identifier, range(1, length(data.aws_availability_zones.this.names) + 1)) : var.public_subnets
  private_subnets  = var.private_subnets == null ? formatlist("%s.%s.64/26", var.vpc_cidr_block_identifier, range(1, length(data.aws_availability_zones.this.names) + 1)) : var.private_subnets
  database_subnets = var.database_subnets == null ? formatlist("%s.%s.128/26", var.vpc_cidr_block_identifier, range(1, length(data.aws_availability_zones.this.names) + 1)) : var.database_subnets
  intra_subnets    = var.intra_subnets == null ? formatlist("%s.%s.192/26", var.vpc_cidr_block_identifier, range(1, length(data.aws_availability_zones.this.names) + 1)) : var.intra_subnets
}

module "vpc" {
  source                       = "terraform-aws-modules/vpc/aws"
  name                         = var.vpc_name
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

module "vpc_endpoints" {
  source = "terraform-aws-modules/vpc/aws//modules/vpc-endpoints"
  count  = var.create_s3_vpc_endpoint ? 1 : 0

  vpc_id = module.vpc.vpc_id

  endpoints = {
    s3 = {
      # interface endpoint
      service           = "s3"
      tags              = { Name = "s3-vpc-endpoint" }
      auto_accept       = true
      vpc_endpoint_type = "Interface"
      subnet_ids        = module.vpc.intra_subnets
    }
  }

  create_security_group = true
  security_group_name   = "vpc-endpoint-s3"
  security_group_rules = {
    s3_https = {
      type                     = "ingress"
      from_port                = 443
      to_port                  = 443
      protocol                 = "tcp"
      source_security_group_id = module.internal_load_balancer[0].security_group.id
      description              = "HTTPS from Load Balancer"
    },
    s3_http = {
      type                     = "ingress"
      from_port                = 80
      to_port                  = 80
      protocol                 = "tcp"
      source_security_group_id = module.internal_load_balancer[0].security_group.id
      description              = "HTTP from Load Balancer"
    }
  }
}
