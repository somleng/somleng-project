# General Settings

variable "app_name" {
  description = "EB application name"
}

variable "solution_stack_name" {}

variable "env_identifier" {
  description = "Identifier to use when naming Elastic Beanstalk environments"
}

# VPC Settings

variable "vpc_id" {}

variable "ec2_subnets" {
  type = "list"
}

variable "elb_subnets" {
  default = []
}

# EC2 Settings

variable "security_groups" {
  type = "list"
}

variable "web_instance_type" {
  description = "EC2 instance type for Web Server"
  default     = "t2.micro"
}

variable "worker_instance_type" {
  description = "EC2 instance type for Worker"
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

variable "service_role" {
  description = "Elastic Beanstalk service role"
}

# AutoScaling

variable "autoscaling_group_worker_min_size" {
  default = "1"
}

variable "autoscaling_group_worker_max_size" {
  default = "4"
}

variable "autoscaling_group_web_min_size" {
  default = "1"
}

variable "autoscaling_group_web_max_size" {
  default = "4"
}

variable "autoscaling_scale_up_recurrence" {
  default = ""
}

variable "autoscaling_scale_down_recurrence" {
  default = ""
}

# Listener

variable "ssl_certificate_id" {}

# ENV Vars

## Defaults

variable "aws_region" {}

## Rails Specific

variable "rails_env" {
  default = "production"
}

variable "rails_master_key" {}

variable "database_url" {}

variable "db_pool" {
  default = "32"
}

## Application Specific

variable "s3_access_key_id" {
  default = ""
}

variable "s3_secret_access_key" {
  default = ""
}

variable "uploads_bucket" {}

variable "default_url_host" {}

variable "action_mailer_delivery_method" {
  default = "smtp"
}

variable "mailer_sender" {
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
  default = "plain"
}

variable "smtp_enable_starttls_auto" {
  default = "true"
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

variable "twilreapi_admin_basic_auth_user" {
  default = ""
}

variable "twilreapi_admin_basic_auth_password" {
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
