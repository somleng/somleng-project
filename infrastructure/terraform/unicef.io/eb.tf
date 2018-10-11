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
  vpc_id          = "${module.vpc.vpc_id}"
  private_subnets = "${module.vpc.private_subnets}"
  public_subnets  = "${module.vpc.public_subnets}"

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
  database_url     = "postgres://${module.twilreapi_db.db_username}:${module.twilreapi_db.db_password}@${module.twilreapi_db.db_instance_endpoint}/${module.twilreapi_db.db_instance_name}"
  db_pool          = "${local.twilreapi_db_pool}"

  ## Application Specific
  s3_access_key_id     = "${module.s3_iam.s3_access_key_id}"
  s3_secret_access_key = "${module.s3_iam.s3_secret_access_key}"
  uploads_bucket       = "${aws_s3_bucket.cdr.id}"
  default_url_host     = "${local.twilreapi_url_host}"
  smtp_username        = "${module.ses.smtp_username}"
  smtp_password        = "${module.ses.smtp_password}"

  ### Twilreapi Specific
  outbound_call_drb_uri       = "${local.twilreapi_outbound_call_drb_uri}"
  outbound_call_job_queue_url = "${module.twilreapi_eb_outbound_call_worker_env.aws_sqs_queue_url}"
}

module "twilreapi_deploy" {
  source = "../modules/deploy"

  eb_env_id    = "${module.twilreapi_eb_app_env.web_id}"
  repo         = "${local.twilreapi_deploy_repo}"
  branch       = "${local.twilreapi_deploy_branch}"
  travis_token = "${var.travis_token}"
}

module "twilreapi_eb_outbound_call_worker_env" {
  source = "../modules/eb_env"

  # General Settings
  app_name            = "${aws_elastic_beanstalk_application.twilreapi.name}"
  solution_stack_name = "${module.twilreapi_eb_solution_stack.ruby_name}"
  env_identifier      = "${local.twilreapi_identifier}-caller"
  tier                = "Worker"

  # VPC
  vpc_id          = "${module.vpc.vpc_id}"
  private_subnets = "${module.vpc.private_subnets}"
  public_subnets  = "${module.vpc.public_subnets}"

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
  database_url     = "postgres://${module.twilreapi_db.db_username}:${module.twilreapi_db.db_password}@${module.twilreapi_db.db_instance_endpoint}/${module.twilreapi_db.db_instance_name}"
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
  outbound_call_drb_uri = "${local.twilreapi_outbound_call_drb_uri}"
}
