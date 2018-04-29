module "eb_worker" {
  source = "../eb_env"

  # General Settings
  app_name            = "${var.app_name}"
  env_identifier      = "${var.env_identifier}"
  solution_stack_name = "${var.solution_stack_name}"
  tier                = "Worker"

  # VPC
  vpc_id          = "${var.vpc_id}"
  private_subnets = "${var.private_subnets}"
  public_subnets  = "${var.public_subnets}"

  # EC2 Settings
  security_groups   = "${var.security_groups}"
  instance_type     = "${var.worker_instance_type}"
  ec2_instance_role = "${var.ec2_instance_role}"

  # Elastic Beanstalk Environment
  service_role = "${var.service_role}"

  # ENV Vars
  ## Defaults
  aws_region = "${var.aws_region}"

  # Rails Specific
  rails_skip_asset_compilation = "true"
  rails_env                    = "${var.rails_env}"
  rails_master_key             = "${var.rails_master_key}"
  database_url                 = "${var.database_url}"
  db_pool                      = "${var.db_pool}"

  # Application Specific
  s3_access_key_id            = "${var.s3_access_key_id}"
  s3_secret_access_key        = "${var.s3_secret_access_key}"
  uploads_bucket              = "${var.uploads_bucket}"
  process_active_elastic_jobs = "true"
  default_url_host            = "${var.default_url_host}"

  ## Twilreapi Specific
  outbound_call_drb_uri       = "${var.outbound_call_drb_uri}"
  outbound_call_job_queue_url = "${var.outbound_call_job_queue_url}"
}

module "eb_web" {
  source = "../eb_env"

  # General Settings
  app_name            = "${var.app_name}"
  env_identifier      = "${var.env_identifier}"
  solution_stack_name = "${var.solution_stack_name}"
  tier                = "WebServer"

  # VPC
  vpc_id          = "${var.vpc_id}"
  private_subnets = "${var.private_subnets}"
  public_subnets  = "${var.public_subnets}"

  # EC2 Settings
  security_groups   = "${var.security_groups}"
  instance_type     = "${var.web_instance_type}"
  ec2_instance_role = "${var.ec2_instance_role}"

  # Elastic Beanstalk Environment
  service_role = "${var.service_role}"

  # Listener
  ssl_certificate_id = "${var.ssl_certificate_id}"

  # ENV Vars
  ## Defaults
  aws_region = "${var.aws_region}"

  # Rails Specific
  rails_skip_asset_compilation = "false"
  rails_env                    = "${var.rails_env}"
  rails_master_key             = "${var.rails_master_key}"
  database_url                 = "${var.database_url}"
  db_pool                      = "${var.db_pool}"

  # Application Specific
  s3_access_key_id            = "${var.s3_access_key_id}"
  s3_secret_access_key        = "${var.s3_secret_access_key}"
  uploads_bucket              = "${var.uploads_bucket}"
  process_active_elastic_jobs = "false"
  default_url_host            = "${var.default_url_host}"
  default_queue_url           = "${module.eb_worker.aws_sqs_queue_url}"

  ## Twilreapi Specific
  outbound_call_job_queue_url = "${var.outbound_call_job_queue_url}"
}
