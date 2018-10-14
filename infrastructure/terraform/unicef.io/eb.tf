locals {
  twilreapi_url_host                        = "https://${local.twilreapi_route53_record_name}.${local.route53_domain_name}"
  twilreapi_db_host                         = "postgres://${module.twilreapi_db.db_username}:${module.twilreapi_db.db_password}@${module.twilreapi_db.db_instance_endpoint}/${module.twilreapi_db.db_instance_name}"
  twilreapi_admin_basic_auth_password       = "${data.aws_kms_secrets.secrets.plaintext["twilreapi_admin_basic_auth_password"]}"
  somleng_adhearsion_drb_host               = "druby://${module.route53_record_somleng_adhearsion.fqdn}:${local.somleng_adhearsion_drb_port}"
  somleng_freeswitch_xmpp_host              = "${module.route53_record_somleng_freeswitch.fqdn}"
  somleng_freeswitch_mod_rayo_password      = "${data.aws_kms_secrets.secrets.plaintext["somleng_freeswitch_mod_rayo_password"]}"
  somleng_freeswitch_mod_rayo_shared_secret = "${data.aws_kms_secrets.secrets.plaintext["somleng_freeswitch_mod_rayo_shared_secret"]}"
}

resource "aws_elastic_beanstalk_application" "twilreapi" {
  name        = "somleng-twilreapi"
  description = "Somleng Twilio REST API"
}

module "twilreapi_eb_app_env" {
  source = "../modules/eb_app_env"

  # General Settings
  app_name            = "${aws_elastic_beanstalk_application.twilreapi.name}"
  solution_stack_name = "${module.twilreapi_eb_solution_stack.ruby_name}"
  env_identifier      = "${local.twilreapi_identifier}"

  # VPC
  vpc_id      = "${module.vpc.vpc_id}"
  elb_subnets = "${module.vpc.public_subnets}"
  ec2_subnets = "${module.vpc.private_subnets}"

  # EC2 Settings
  security_groups   = ["${module.twilreapi_db.security_group}"]
  ec2_instance_role = "${module.eb_iam.eb_ec2_instance_role}"

  # Elastic Beanstalk Environment
  service_role = "${module.eb_iam.eb_service_role}"

  # Listener
  ssl_certificate_id = "${aws_acm_certificate.unicef_io.arn}"

  # ENV Vars
  ## Defaults
  aws_region = "${var.aws_region}"

  ## Rails Specific
  rails_master_key = "${data.aws_kms_secrets.secrets.plaintext["twilreapi_rails_master_key"]}"
  database_url     = "${local.twilreapi_db_host}"
  db_pool          = "${local.twilreapi_db_pool}"

  ## Application Specific
  s3_access_key_id     = "${module.s3_iam.s3_access_key_id}"
  s3_secret_access_key = "${module.s3_iam.s3_secret_access_key}"
  uploads_bucket       = "${aws_s3_bucket.cdr.id}"
  default_url_host     = "${local.twilreapi_url_host}"
  smtp_username        = "${module.ses.smtp_username}"
  smtp_password        = "${module.ses.smtp_password}"

  ### Twilreapi Specific
  outbound_call_drb_uri               = "${local.somleng_adhearsion_drb_host}"
  outbound_call_job_queue_url         = "${module.twilreapi_eb_outbound_call_worker_env.aws_sqs_queue_url}"
  twilreapi_admin_basic_auth_user     = "${local.twilreapi_admin_basic_auth_user}"
  twilreapi_admin_basic_auth_password = "${local.twilreapi_admin_basic_auth_password}"
}

module "twilreapi_eb_outbound_call_worker_env" {
  source = "../modules/eb_env"

  # General Settings
  app_name            = "${aws_elastic_beanstalk_application.twilreapi.name}"
  solution_stack_name = "${module.twilreapi_eb_solution_stack.ruby_name}"
  env_identifier      = "${local.twilreapi_identifier}-caller"
  tier                = "Worker"

  # VPC
  vpc_id      = "${module.vpc.vpc_id}"
  ec2_subnets = "${module.vpc.private_subnets}"

  # EC2 Settings
  security_groups   = ["${module.twilreapi_db.security_group}"]
  instance_type     = "t2.nano"
  ec2_instance_role = "${module.eb_iam.eb_ec2_instance_role}"

  # Elastic Beanstalk Environment
  service_role = "${module.eb_iam.eb_service_role}"

  # ENV Vars
  ## Defaults
  aws_region = "${var.aws_region}"

  ## Rails Specific
  rails_env        = "production"
  rails_master_key = "${data.aws_kms_secrets.secrets.plaintext["twilreapi_rails_master_key"]}"
  database_url     = "${local.twilreapi_db_host}"
  db_pool          = "${local.twilreapi_db_pool}"

  ## Application Specific
  s3_access_key_id            = "${module.s3_iam.s3_access_key_id}"
  s3_secret_access_key        = "${module.s3_iam.s3_secret_access_key}"
  uploads_bucket              = "${aws_s3_bucket.cdr.id}"
  process_active_elastic_jobs = "true"
  default_url_host            = "${local.twilreapi_url_host}"
  smtp_username               = "${module.ses.smtp_username}"
  smtp_password               = "${module.ses.smtp_password}"

  ### Twilreapi Specific
  outbound_call_drb_uri = "${local.somleng_adhearsion_drb_host}"
}

module "twilreapi_deploy" {
  source = "../modules/deploy"

  eb_env_id    = "${module.twilreapi_eb_app_env.web_id}"
  repo         = "${local.twilreapi_deploy_repo}"
  branch       = "${local.twilreapi_deploy_branch}"
  travis_token = "${var.travis_token}"
}

resource "aws_elastic_beanstalk_application" "somleng_adhearsion" {
  name        = "somleng-adhearsion"
  description = "Somleng Adhearsion"
}

module "somleng_adhearsion_webserver" {
  source = "../modules/eb_env"

  # General Settings
  app_name            = "${aws_elastic_beanstalk_application.somleng_adhearsion.name}"
  solution_stack_name = "${module.somleng_adhearsion_eb_solution_stack.multi_container_docker_name}"
  env_identifier      = "${local.somleng_adhearsion_identifier}"
  tier                = "WebServer"

  # VPC
  vpc_id      = "${module.vpc.vpc_id}"
  elb_subnets = "${module.vpc.intra_subnets}"
  ec2_subnets = "${module.vpc.private_subnets}"
  elb_scheme  = "internal"

  # EC2 Settings
  instance_type     = "t2.micro"
  ec2_instance_role = "${module.eb_iam.eb_ec2_instance_role}"

  # Elastic Beanstalk Environment
  service_role       = "${module.eb_iam.eb_service_role}"
  load_balancer_type = "network"

  # Listener
  default_listener_enabled = "false"
  ssl_listener_enabled     = "false"

  drb_listener_enabled = "true"
  drb_listener_port    = "${local.somleng_adhearsion_drb_port}"

  # Default Process
  default_process_protocol = "TCP"
  default_process_port     = "${local.somleng_adhearsion_drb_port}"

  # ENV Vars
  ## Defaults
  aws_region = "${var.aws_region}"

  # Somleng Adhearsion Specific
  adhearsion_app                                   = "true"
  adhearsion_env                                   = "production"
  adhearsion_core_host                             = "${local.somleng_freeswitch_xmpp_host}"
  adhearsion_core_port                             = "${local.somleng_freeswitch_xmpp_port}"
  adhearsion_core_username                         = "${local.somleng_adhearsion_core_username}"
  adhearsion_core_password                         = "${local.somleng_freeswitch_mod_rayo_password}"
  adhearsion_drb_port                              = "${local.somleng_adhearsion_drb_port}"
  adhearsion_twilio_rest_api_phone_calls_url       = "${local.twilreapi_url_host}/api/admin/phone_calls"
  adhearsion_twilio_rest_api_phone_call_events_url = "${local.twilreapi_url_host}/api/admin/phone_call_events"
}

module "somleng_adhearsion_deploy" {
  source = "../modules/deploy"

  eb_env_id    = "${module.somleng_adhearsion_webserver.id}"
  repo         = "${local.somleng_adhearsion_deploy_repo}"
  branch       = "${local.somleng_adhearsion_deploy_branch}"
  travis_token = "${var.travis_token}"
}

resource "aws_elastic_beanstalk_application" "somleng_freeswitch" {
  name        = "somleng-freeswitch"
  description = "Somleng FreeSWITCH"
}

module "somleng_freeswitch_webserver" {
  source = "../modules/eb_env"

  # General Settings
  app_name            = "${aws_elastic_beanstalk_application.somleng_freeswitch.name}"
  solution_stack_name = "${module.somleng_freeswitch_eb_solution_stack.multi_container_docker_name}"
  env_identifier      = "${local.somleng_freeswitch_identifier}"
  tier                = "WebServer"

  # VPC
  vpc_id                      = "${module.vpc.vpc_id}"
  elb_subnets                 = "${module.vpc.intra_subnets}"
  ec2_subnets                 = "${module.vpc.public_subnets}"
  elb_scheme                  = "internal"
  associate_public_ip_address = "true"

  # EC2 Settings
  instance_type     = "t2.micro"
  ec2_instance_role = "${module.eb_iam.eb_ec2_instance_role}"
  security_groups   = ["${aws_security_group.freeswitch.id}"]

  # Elastic Beanstalk Environment
  service_role       = "${module.eb_iam.eb_service_role}"
  load_balancer_type = "network"

  # Listener
  default_listener_enabled = "false"
  ssl_listener_enabled     = "false"

  xmpp_listener_enabled = "true"
  xmpp_listener_port    = "${local.somleng_freeswitch_xmpp_port}"

  # Default Process
  default_process_protocol = "TCP"
  default_process_port     = "${local.somleng_freeswitch_xmpp_port}"

  # Autoscaling
  autoscaling_group_max_size = "1"

  # ENV Vars
  ## Defaults
  aws_region = "${var.aws_region}"

  # FreeSWITCH Specific

  freeswitch_app = "true"
  fs_external_ip = "${aws_eip.freeswitch.public_ip}"
  fs_mod_rayo_port          = "${local.somleng_freeswitch_xmpp_port}"
  fs_mod_rayo_domain_name   = "${local.somleng_freeswitch_mod_rayo_domain_name}"
  fs_mod_rayo_user          = "${local.somleng_freeswitch_mod_rayo_user}"
  fs_mod_rayo_password      = "${local.somleng_freeswitch_mod_rayo_password}"
  fs_mod_rayo_shared_secret = "${local.somleng_freeswitch_mod_rayo_shared_secret}"
  fs_mod_json_cdr_url  = "${local.twilreapi_url_host}/api/admin/call_data_records"
  fs_mod_json_cdr_cred = "${local.twilreapi_admin_basic_auth_user}:${local.twilreapi_admin_basic_auth_password}"
}

module "somleng_freeswitch_deploy" {
  source = "../modules/deploy"

  eb_env_id    = "${module.somleng_freeswitch_webserver.id}"
  repo         = "${local.somleng_freeswitch_deploy_repo}"
  branch       = "${local.somleng_freeswitch_deploy_branch}"
  travis_token = "${var.travis_token}"
}
