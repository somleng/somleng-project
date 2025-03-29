module "hydrogen_region" {
  source = "../modules/region"

  vpc_name                                   = "somleng"
  alias                                      = "hydrogen"
  vpc_cidr_block                             = "10.10.0.0/22"
  vpc_cidr_block_identifier                  = "10.10"
  public_subnets                             = ["10.10.0.0/26", "10.10.0.64/26", "10.10.0.128/26"]
  private_subnets                            = ["10.10.1.0/26", "10.10.1.64/26", "10.10.1.128/26"]
  database_subnets                           = ["10.10.1.192/26", "10.10.2.0/26", "10.10.2.64/26"]
  intra_subnets                              = ["10.10.2.128/26", "10.10.2.192/26", "10.10.3.0/26"]
  create_public_load_balancer                = true
  create_nat_instance                        = true
  create_internal_load_balancer              = true
  public_load_balancer_name                  = "somleng-application"
  public_load_balancer_security_group_name   = "Somleng Application Load Balancer Security Group"
  internal_load_balancer_name                = "somleng-ialb"
  internal_load_balancer_security_group_name = "Somleng Internal Application Load Balancer Security Group"
  ssl_certificate_domain_name                = "*.somleng.org"
  public_ssl_certificate_subject_alternative_names = [
    "*.app.somleng.org",
    "*.app-staging.somleng.org",
  ]
  internal_ssl_certificate_subject_alternative_names = ["*.hydrogen.somleng.org", "*.internal.somleng.org"]
  route53_zone                                       = aws_route53_zone.somleng_org
  logs_bucket_name                                   = "logs.somleng.org"
  flow_logs_role                                     = aws_iam_role.flow_logs
  nat_instance_custom_routes = {
    "zamtel"                     = "165.57.32.1/32",
    "zamtel_media"               = "165.57.33.2/32",
    "telecom_cambodia_signaling" = "203.223.42.142/32",
    "telecom_cambodia_media1"    = "203.223.42.132/32",
    "telecom_cambodia_media2"    = "203.223.42.148/32"
  }
  create_s3_vpc_endpoint = true
}

module "helium_region" {
  source = "../modules/region"

  vpc_name                                           = "somleng"
  alias                                              = "helium"
  vpc_cidr_block                                     = "10.20.0.0/20"
  vpc_cidr_block_identifier                          = "10.20"
  create_internal_load_balancer                      = true
  ssl_certificate_domain_name                        = "*.somleng.org"
  internal_ssl_certificate_subject_alternative_names = ["*.helium.somleng.org"]
  route53_zone                                       = aws_route53_zone.somleng_org
  flow_logs_role                                     = aws_iam_role.flow_logs

  logs_bucket_name = "logs-helium.somleng.org"

  providers = {
    aws = aws.helium
  }

  create_s3_vpc_endpoint = false
}

module "region_peering_hydrogen_to_helium" {
  source = "../modules/region_peering"

  requester_region = module.hydrogen_region
  accepter_region  = module.helium_region

  providers = {
    aws.requester = aws
    aws.accepter  = aws.helium
  }
}
