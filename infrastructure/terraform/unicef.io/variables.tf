locals {
  route53_domain_name          = "unicef.io"
  internal_route53_domain_name = "internal.unicef.io"
  eb_zone_id                   = "Z16FZ9L249IFLT"
}

locals {
  twilreapi_identifier          = "somleng-twilreapi"
  twilreapi_major_ruby_version  = "2.5"
  twilreapi_route53_record_name = "somleng"
  twilreapi_db_pool             = "32"

  twilreapi_db_master_password                  = "AQICAHgs11zuKnnKl+eQEK6tg6GtBF2O7KMpmfiRNwqCJR1W5gGjECePCTl7S3tMcnMtc3V9AAAAdTBzBgkqhkiG9w0BBwagZjBkAgEAMF8GCSqGSIb3DQEHATAeBglghkgBZQMEAS4wEQQMcs3PCKpQF+68Gb/9AgEQgDLfOVD4Iz3at8TmcWZ4rpecR19IrJ0ydBHtQo3t3RZVT7V/U/iWlza82UJrVIHqyNiz8w=="
  twilreapi_rails_master_key                    = "AQICAHgs11zuKnnKl+eQEK6tg6GtBF2O7KMpmfiRNwqCJR1W5gHMMf0HnYWU760xBU3k2XCBAAAAfjB8BgkqhkiG9w0BBwagbzBtAgEAMGgGCSqGSIb3DQEHATAeBglghkgBZQMEAS4wEQQMk8+tXcuR3lNUJfmeAgEQgDuDe0ZuQD24V9SwqCkASfU56nkmJeJqe7f9z9nqum6f0L1jrzEK3WubzCjhJq9YS7RjFOAs04anIzx5aA=="
  twilreapi_deploy_repo                         = "somleng/twilreapi"
  twilreapi_deploy_branch                       = "somleng.unicef.io"
  twilreapi_admin_basic_auth_user               = "admin"
  twilreapi_admin_basic_auth_encrypted_password = "AQICAHgs11zuKnnKl+eQEK6tg6GtBF2O7KMpmfiRNwqCJR1W5gGyh4ynRy7SuVvRcw7YGE2EAAAAfjB8BgkqhkiG9w0BBwagbzBtAgEAMGgGCSqGSIb3DQEHATAeBglghkgBZQMEAS4wEQQMh1TYHbWstMbnhdumAgEQgDtVF8kpJSLTEBVJ+S0+euGMeiSO0UBN39m/v7iLlyMs2HxVQ97KVP5wAi8JLTyEhWrlrghvQsXBn29BoQ=="
}

locals {
  somleng_freeswitch_route53_record_name              = "somleng-freeswitch"
  somleng_freeswitch_identifier                       = "somleng-freeswitch"
  somleng_freeswitch_xmpp_port                        = "5222"
  somleng_freeswitch_mod_rayo_domain_name             = "rayo.somleng.org"
  somleng_freeswitch_mod_rayo_user                    = "rayo"
  somleng_freeswitch_mod_rayo_encrypted_password      = "AQICAHgs11zuKnnKl+eQEK6tg6GtBF2O7KMpmfiRNwqCJR1W5gG+QcUcAPqVJnQBvfWSa6wSAAAAfjB8BgkqhkiG9w0BBwagbzBtAgEAMGgGCSqGSIb3DQEHATAeBglghkgBZQMEAS4wEQQMAtHDfHreuPO4dLJBAgEQgDt97ajlIvCma05ag+7JonZ4r5RlPyJQu6CwOuR4IxxmvPWBkUzhtvNOckmrAb4dBMwsaUgMuuGA3P6xDw=="
  somleng_freeswitch_mod_rayo_encrypted_shared_secret = "AQICAHgs11zuKnnKl+eQEK6tg6GtBF2O7KMpmfiRNwqCJR1W5gF19zXn2KBFcViWjXPWfIASAAAAfjB8BgkqhkiG9w0BBwagbzBtAgEAMGgGCSqGSIb3DQEHATAeBglghkgBZQMEAS4wEQQM0jdCamqXW2rb7BsrAgEQgDtvwIHe6PY7uZobf2580crg+G06xBVAekX21LJ1InfNpedr5vqi2kh2tBA5ooSvanUOUM42DCeriMkykw=="
  somleng_freeswitch_deploy_repo                      = "somleng/freeswitch-config"
  somleng_freeswitch_deploy_branch                    = "somleng.unicef.io"
}

locals {
  somleng_adhearsion_route53_record_name = "somleng-adhearsion"
  somleng_adhearsion_identifier          = "somleng-adhearsion"
  somleng_adhearsion_core_username       = "${local.somleng_freeswitch_mod_rayo_user}@${local.somleng_freeswitch_mod_rayo_domain_name}"
  somleng_adhearsion_drb_port            = "9050"
  somleng_adhearsion_deploy_repo         = "somleng/somleng-adhearsion"
  somleng_adhearsion_deploy_branch       = "somleng.unicef.io"
}

locals {
  vpc_name                             = "somleng"
  vpc_cidr_block                       = "10.0.0.0/24"
  vpc_azs                              = ["ap-southeast-1a", "ap-southeast-1b", "ap-southeast-1c"]
  vpc_twilreapi_ec2_subnet_cidr_blocks = ["10.0.0.0/28", "10.0.0.16/28", "10.0.0.32/28"]
  vpc_intra_subnet_cidr_blocks         = ["10.0.0.112/28", "10.0.0.128/28", "10.0.0.144/28"]
  vpc_database_subnet_cidr_blocks      = ["10.0.0.160/28", "10.0.0.176/28", "10.0.0.192/28"]
  vpc_public_subnet_cidr_blocks        = ["10.0.0.208/28", "10.0.0.224/28", "10.0.0.240/28"]
  vpc_private_subnet_cidr_blocks       = "${concat(local.vpc_twilreapi_ec2_subnet_cidr_blocks)}"
}

locals {
  terraform_bucket = "terraform.unicef.io"
}

variable "travis_token" {}

variable "aws_region" {
  default = "ap-southeast-1"
}

variable "terraform_profile" {
  default = "unicef-terraform"
}
