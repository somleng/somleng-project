# General Settings

variable "app_name" {
  description = "Elastic Beanstalk application name"
}

variable "solution_stack_name" {}

variable "env_identifier" {
  description = "Identifier to use when naming Elastic Beanstalk environments"
}

variable "tier" {
  description = "Elastic Beanstalk tier"
}

# VPC Settings

variable "vpc_id" {}

variable "ec2_subnets" {
  type = "list"
}

variable "elb_subnets" {
  default = []
}

variable "elb_scheme" {
  default = "public"
}

variable "associate_public_ip_address" {
  default = "false"
}

# EC2 Settings

variable "security_groups" {
  default = []
}

variable "instance_type" {
  description = "EC2 instance type"
  default     = "t2.micro"
}

variable "ec2_instance_role" {
  description = "Elastic Beanstalk EC2 role"
}

# CloudWatch Logs

variable "cloudwatch_enabled" {
  default = "true"
}

variable "cloudwatch_delete_on_terminate" {
  default = "false"
}

variable "cloudwatch_retention_in_days" {
  default = "30"
}

# Elastic Beanstalk Environment

variable "environment_type" {
  default = "LoadBalanced"
}

variable "service_role" {
  description = "Elastic Beanstalk service role"
}

variable "load_balancer_type" {
  default = "application"
}

# Default Process

variable "default_process_port" {
  default = "80"
}

variable "default_process_protocol" {
  default = "HTTP"
}

variable "health_check_path" {
  default = "/health_checks"
}

# Listeners

variable "default_listener_enabled" {
  default = "true"
}

variable "ssl_listener_enabled" {
  default = "true"
}

variable "ssl_listener_protocol" {
  default = "HTTPS"
}

variable "ssl_certificate_id" {
  default = ""
}

variable "ssl_security_policy" {
  default = "ELBSecurityPolicy-TLS-1-1-2017-01"
}

variable "drb_listener_enabled" {
  default = "false"
}

variable "drb_listener_protocol" {
  default = "TCP"
}

variable "drb_listener_port" {
  default = ""
}

variable "xmpp_listener_enabled" {
  default = "false"
}

variable "xmpp_listener_protocol" {
  default = "TCP"
}

variable "xmpp_listener_port" {
  default = ""
}

# Autoscaling

variable "autoscaling_group_min_size" {
  default = "1"
}

variable "autoscaling_group_max_size" {
  default = "4"
}

variable "autoscaling_scale_up_recurrence" {
  default = ""
}

variable "autoscaling_scale_down_recurrence" {
  default = ""
}

# ENV Vars

## Defaults

variable "aws_region" {}

## Rails Specific

variable "rails_skip_asset_compilation" {
  default = ""
}

variable "rails_env" {
  default = ""
}

variable "rails_master_key" {
  default = ""
}

variable "database_url" {
  default = ""
}

variable "db_pool" {
  default = ""
}

## Application Specific

variable "s3_access_key_id" {
  default = ""
}

variable "s3_secret_access_key" {
  default = ""
}

variable "uploads_bucket" {
  default = ""
}

variable "process_active_elastic_jobs" {
  default = ""
}

variable "default_queue_url" {
  default = ""
}

variable "default_url_host" {
  description = "URL Host of Application. e.g. https://www.example.com"
  default     = ""
}

variable "mailer_sender" {
  default = ""
}

variable "action_mailer_delivery_method" {
  default = ""
}

variable "smtp_address" {
  default = ""
}

variable "smtp_port" {
  default = ""
}

variable "smtp_username" {
  default = ""
}

variable "smtp_password" {
  default = ""
}

variable "smtp_authentication_method" {
  default = ""
}

variable "smtp_enable_starttls_auto" {
  default = ""
}

### Twilreapi

variable "outbound_call_drb_uri" {
  default = ""
}

variable "aws_sns_message_processor_job_queue_url" {
  default = ""
}

variable "call_data_record_job_queue_url" {
  default = ""
}

variable "outbound_call_job_queue_url" {
  default = ""
}

variable "recording_processor_job_queue_url" {
  default = ""
}

variable "recording_status_callback_notifier_job_queue_url" {
  default = ""
}

variable "status_callback_notifier_job_queue_url" {
  default = ""
}

### SCFM

variable "fetch_remote_call_job_queue_url" {
  default = ""
}

variable "queue_remote_call_job_queue_url" {
  default = ""
}

variable "run_batch_operation_job_queue_url" {
  default = ""
}

variable "scheduler_job_queue_url" {
  default = ""
}

variable "audio_bucket" {
  default = ""
}

### Somleng Adhearsion

variable "adhearsion_app" {
  default = "false"
}

variable "adhearsion_env" {
  default = "production"
}

variable "adhearsion_core_host" {
  default = ""
}

variable "adhearsion_core_port" {
  default = ""
}

variable "adhearsion_core_username" {
  default = ""
}

variable "adhearsion_core_password" {
  default = ""
}

variable "adhearsion_drb_port" {
  default = ""
}

variable "adhearsion_twilio_rest_api_phone_calls_url" {
  default = ""
}

variable "adhearsion_twilio_rest_api_phone_call_events_url" {
  default = ""
}
