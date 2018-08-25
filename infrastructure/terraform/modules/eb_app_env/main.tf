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

  # AutoScaling
  autoscaling_group_min_size = "${var.autoscaling_group_worker_min_size}"
  autoscaling_group_max_size = "${var.autoscaling_group_worker_max_size}"

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
  s3_access_key_id              = "${var.s3_access_key_id}"
  s3_secret_access_key          = "${var.s3_secret_access_key}"
  uploads_bucket                = "${var.uploads_bucket}"
  process_active_elastic_jobs   = "true"
  default_url_host              = "${var.default_url_host}"
  mailer_sender                 = "${var.mailer_sender}"
  action_mailer_delivery_method = "${var.action_mailer_delivery_method}"
  smtp_address                  = "${var.smtp_address}"
  smtp_port                     = "${var.smtp_port}"
  smtp_username                 = "${var.smtp_username}"
  smtp_password                 = "${var.smtp_password}"
  smtp_authentication_method    = "${var.smtp_authentication_method}"
  smtp_enable_starttls_auto     = "${var.smtp_enable_starttls_auto}"

  ## Twilreapi Specific
  outbound_call_drb_uri       = "${var.outbound_call_drb_uri}"
  outbound_call_job_queue_url = "${var.outbound_call_job_queue_url}"

  ## SCFM Specific
  audio_bucket = "${var.audio_bucket}"
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

  # AutoScaling
  autoscaling_group_min_size        = "${var.autoscaling_group_web_min_size}"
  autoscaling_group_max_size        = "${var.autoscaling_group_web_max_size}"
  autoscaling_scale_up_recurrence   = "${var.autoscaling_scale_up_recurrence}"
  autoscaling_scale_down_recurrence = "${var.autoscaling_scale_down_recurrence}"

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
  s3_access_key_id              = "${var.s3_access_key_id}"
  s3_secret_access_key          = "${var.s3_secret_access_key}"
  uploads_bucket                = "${var.uploads_bucket}"
  process_active_elastic_jobs   = "false"
  default_url_host              = "${var.default_url_host}"
  default_queue_url             = "${module.eb_worker.aws_sqs_queue_url}"
  mailer_sender                 = "${var.mailer_sender}"
  action_mailer_delivery_method = "${var.action_mailer_delivery_method}"
  smtp_address                  = "${var.smtp_address}"
  smtp_port                     = "${var.smtp_port}"
  smtp_username                 = "${var.smtp_username}"
  smtp_password                 = "${var.smtp_password}"
  smtp_authentication_method    = "${var.smtp_authentication_method}"
  smtp_enable_starttls_auto     = "${var.smtp_enable_starttls_auto}"

  ## Twilreapi Specific
  outbound_call_job_queue_url = "${var.outbound_call_job_queue_url}"

  ## SCFM Specific
  fetch_remote_call_job_queue_url   = "${var.fetch_remote_call_job_queue_url}"
  queue_remote_call_job_queue_url   = "${var.queue_remote_call_job_queue_url}"
  run_batch_operation_job_queue_url = "${var.run_batch_operation_job_queue_url}"
  scheduler_job_queue_url           = "${var.scheduler_job_queue_url}"
  audio_bucket                      = "${var.audio_bucket}"
}
