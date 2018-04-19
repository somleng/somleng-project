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

variable "private_subnets" {
  type        = "list"
  description = "EC2 subnets"
}

variable "public_subnets" {
  type        = "list"
  description = "ELB subnets"
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

variable "service_role" {
  description = "Elastic Beanstalk service role"
}

# Listener

variable "ssl_certificate_id" {
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
