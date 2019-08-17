module "somleng_freeswitch_eb_app" {
  source = "../modules/eb_app"

  app_identifier   = "${local.somleng_freeswitch_identifier}"
  service_role_arn = "${module.eb_iam.eb_service_role_arn}"
}

module "freeswitch_simulator" {
  source = "../modules/freeswitch"

  app_name       = "${module.somleng_freeswitch_eb_app.app_name}"
  env_identifier = "${local.somleng_freeswitch_identifier}-simulator"

  vpc_id                          = "${module.vpc.vpc_id}"
  elb_subnets                     = "${module.vpc.intra_subnets}"
  ec2_subnets                     = "${module.vpc.public_subnets}"
  ec2_instance_role               = "${module.eb_iam.eb_ec2_instance_role}"
  eb_service_role                 = "${module.eb_iam.eb_service_role}"
  aws_region                      = "${var.aws_region}"
  xmpp_listener_enabled           = "false"
  associate_eip_event_detail_type = "${module.associate_eip.event_detail_type}"
  associate_eip_lambda_arn        = "${module.associate_eip.lambda_arn}"
  eip_allocation_id_tag_key       = "${module.associate_eip.eip_allocation_id_tag_key}"
  simulator                       = "true"
}

module "freeswitch_main" {
  source = "../modules/freeswitch"

  app_name       = "${module.somleng_freeswitch_eb_app.app_name}"
  env_identifier = "${local.somleng_freeswitch_identifier}"

  vpc_id                          = "${module.vpc.vpc_id}"
  elb_subnets                     = "${module.vpc.intra_subnets}"
  ec2_subnets                     = "${module.vpc.public_subnets}"
  ec2_instance_role               = "${module.eb_iam.eb_ec2_instance_role}"
  eb_service_role                 = "${module.eb_iam.eb_service_role}"
  aws_region                      = "${var.aws_region}"
  xmpp_listener_enabled           = "true"
  associate_eip_event_detail_type = "${module.associate_eip.event_detail_type}"
  associate_eip_lambda_arn        = "${module.associate_eip.lambda_arn}"
  eip_allocation_id_tag_key       = "${module.associate_eip.eip_allocation_id_tag_key}"

  mod_rayo_domain_name   = "${local.somleng_freeswitch_mod_rayo_domain_name}"
  mod_rayo_user          = "${local.somleng_freeswitch_mod_rayo_user}"
  mod_rayo_password      = "${local.somleng_freeswitch_mod_rayo_password}"
  mod_rayo_shared_secret = "${local.somleng_freeswitch_mod_rayo_shared_secret}"
  mod_json_cdr_url       = "https://${local.twilreapi_internal_api_fqdn}/call_data_records"
  mod_json_cdr_cred      = "${local.twilreapi_internal_api_credentials}"
}
