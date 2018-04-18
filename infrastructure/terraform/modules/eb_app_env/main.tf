module "eb_worker" {
  source = "../eb_env"

  app_name            = "${var.app_name}"
  tier                = "Worker"
  env_identifier      = "${var.env_identifier}"
  instance_type       = "${var.instance_type}"
  solution_stack_name = "${var.solution_stack_name}"

  vpc_id            = "${var.vpc_id}"
  private_subnets   = "${var.private_subnets}"
  public_subnets    = "${var.public_subnets}"
  security_groups   = "${var.security_groups}"
  service_role      = "${var.service_role}"
  ec2_instance_role = "${var.ec2_instance_role}"

  database_url                = "${var.database_url}"
  rails_master_key            = "${var.rails_master_key}"
  aws_region                  = "${var.aws_region}"
  db_pool                     = "${var.db_pool}"
  process_active_elastic_jobs = "true"
  s3_access_key_id            = "${var.s3_access_key_id}"
  s3_secret_access_key        = "${var.s3_secret_access_key}"
  uploads_bucket              = "${var.uploads_bucket}"
  default_url_host            = "${var.default_url_host}"
  outbound_call_drb_uri       = "${var.outbound_call_drb_uri}"
  outbound_call_job_queue_url = "${var.outbound_call_job_queue_url}"
}

module "eb_web" {
  source = "../eb_env"

  app_name            = "${var.app_name}"
  env_identifier      = "${var.env_identifier}"
  tier                = "WebServer"
  instance_type       = "${var.instance_type}"
  solution_stack_name = "${var.solution_stack_name}"

  vpc_id            = "${var.vpc_id}"
  private_subnets   = "${var.private_subnets}"
  public_subnets    = "${var.public_subnets}"
  security_groups   = "${var.security_groups}"
  service_role      = "${var.service_role}"
  ec2_instance_role = "${var.ec2_instance_role}"

  database_url                 = "${var.database_url}"
  rails_master_key             = "${var.rails_master_key}"
  aws_region                   = "${var.aws_region}"
  db_pool                      = "${var.db_pool}"
  default_queue_url            = "${module.eb_worker.aws_sqs_queue_url}"
  s3_access_key_id             = "${var.s3_access_key_id}"
  s3_secret_access_key         = "${var.s3_secret_access_key}"
  uploads_bucket               = "${var.uploads_bucket}"
  ssl_certificate_id           = "${var.ssl_certificate_id}"
  rails_skip_asset_compilation = "false"
  default_url_host             = "${var.default_url_host}"
  outbound_call_drb_uri        = "${var.outbound_call_drb_uri}"
  outbound_call_job_queue_url  = "${var.outbound_call_job_queue_url}"
}
