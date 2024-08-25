module "vpc_hydrogen" {
  source                                     = "../modules/regional_vpc"
  name                                       = "somleng"
  vpc_cidr_block                             = "10.10.0.0/22"
  vpc_cidr_block_identifier                  = "10.10"
  public_subnets                             = ["10.10.0.0/26", "10.10.0.64/26", "10.10.0.128/26"]
  private_subnets                            = ["10.10.1.0/26", "10.10.1.64/26", "10.10.1.128/26"]
  database_subnets                           = ["10.10.1.192/26", "10.10.2.0/26", "10.10.2.64/26"]
  intra_subnets                              = ["10.10.2.128/26", "10.10.2.192/26", "10.10.3.0/26"]
  create_public_load_balancer                = true
  public_load_balancer_name                  = "somleng-application"
  public_load_balancer_security_group_name   = "Somleng Application Load Balancer Security Group"
  create_internal_load_balancer              = true
  internal_load_balancer_name                = "somleng-ialb"
  internal_load_balancer_security_group_name = "Somleng Internal Application Load Balancer Security Group"
  ssl_certificate_domain_name                = "*.somleng.org"
  public_ssl_certificate_subject_alternative_names = [
    "*.app.somleng.org",
    "*.app-staging.somleng.org",
  ]
  internal_ssl_certificate_subject_alternative_names = ["*.internal.somleng.org"]
  route53_zone                                       = aws_route53_zone.somleng_org
  logs_bucket_name                                   = "logs.somleng.org"
}

module "vpc_helium" {
  source                        = "../modules/regional_vpc"
  name                          = "somleng"
  vpc_cidr_block                = "10.20.0.0/20"
  vpc_cidr_block_identifier     = "10.20"
  create_internal_load_balancer = true
  ssl_certificate_domain_name   = "*.somleng.org"
  route53_zone                  = aws_route53_zone.somleng_org

  logs_bucket_name = "logs-helium.somleng.org"

  providers = {
    aws = aws.helium
  }
}

module "vpc_peering_hydrogen_to_helium" {
  source = "../modules/vpc_peering"

  requester_alias  = "hydrogen"
  accepter_alias   = "helium"
  requester_vpc_id = module.vpc_hydrogen.vpc.vpc_id
  accepter_vpc_id  = module.vpc_helium.vpc.vpc_id

  providers = {
    aws.requester = aws
    aws.accepter  = aws.helium
  }
}
