locals {
  route53_domain_name          = "somleng.org"
  internal_route53_domain_name = "internal.somleng.org"
  eb_zone_id                   = "Z16FZ9L249IFLT"
}

locals {
  rails_db_pool = "32"
}

locals {
  twilreapi_identifier                  = "somleng-twilreapi"
  twilreapi_route53_record_name         = "twilreapi"
  twilreapi_deploy_repo                 = "somleng/twilreapi"
  twilreapi_deploy_branch               = "master"
  twilreapi_internal_api_http_auth_user = "admin"
}

locals {
  somleng_freeswitch_route53_record_name     = "somleng-freeswitch"
  somleng_freeswitch_identifier              = "somleng-freeswitch"
  somleng_freeswitch_xmpp_port               = "5222"
  somleng_freeswitch_mod_rayo_domain_name    = "rayo.somleng.org"
  somleng_freeswitch_mod_rayo_user           = "rayo"
  somleng_freeswitch_deploy_repo             = "somleng/freeswitch-config"
  somleng_freeswitch_deploy_branch           = "master"
  somleng_freeswitch_simulator_deploy_branch = "simulator"
}

locals {
  somleng_adhearsion_route53_record_name = "somleng-adhearsion"
  somleng_adhearsion_identifier          = "somleng-adhearsion"
  somleng_adhearsion_core_username       = "${local.somleng_freeswitch_mod_rayo_user}@${local.somleng_freeswitch_mod_rayo_domain_name}"
  somleng_adhearsion_drb_port            = "9050"
  somleng_adhearsion_deploy_repo         = "somleng/somleng-adhearsion"
  somleng_adhearsion_deploy_branch       = "master"
}

locals {
  scfm_route53_record_name = "scfm"
  scfm_identifier          = "somleng-scfm"
  scfm_deploy_repo         = "somleng/somleng-scfm"
  scfm_deploy_branch       = "master"
}

variable "aws_region" {
  default = "ap-southeast-1"
}