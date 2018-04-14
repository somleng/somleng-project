variable "app_name" {
  description = "EB application name"
}

variable "solution_stack_name" {}

variable "tier" {
  description = "EB tier"
}

variable "env_identifier" {
  default = ""
  description = "ENV identifier to use when naming resources"
}

variable "name" {
  default = ""
}

variable "rails_env" {
  default = "production"
}

variable "default_url_host" {
  default = ""
}

variable "aws_region" {
  default = ""
}

variable "vpc_id" {
  description = "The ID of the VPC"
}

variable "private_subnets" {
  type        = "list"
  description = "EC2 subnets"
}

variable "public_subnets" {
  type        = "list"
  description = "ELB subnets"
}

variable "service_role" {
  description = "EB service role"
}

variable "ec2_instance_role" {
  description = "EB EC2 role"
}

variable "db_pool" {
  default = "48"
}

variable "instance_type" {
  description = "EC2 instance type"
  default     = "t2.micro"
}

variable "rails_skip_asset_compilation" {
  default = "true"
}

variable "process_active_elastic_jobs" {
  default = "false"
}

variable "security_groups" {
  default = []
}

variable "database_url" {
  default = ""
}

variable "rails_master_key" {
  default = ""
}

variable "aws_sqs_queue_url" {
  default = ""
}

variable "s3_access_key_id" {
  default = ""
}

variable "s3_secret_access_key" {
  default = ""
}

variable "ssl_certificate_id" {
  default = ""
}

variable "cloudwatch_enabled" {
  default = "false"
}

variable "cloudwatch_delete_on_terminate" {
  default = "false"
}

variable "cloudwatch_retention_in_days" {
  default = "30"
}
