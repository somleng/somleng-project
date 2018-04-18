variable "app_name" {
  description = "EB application name"
}

variable "solution_stack_name" {}

variable "env_identifier" {
  description = "Env identifier to use when naming resources"
}

variable "aws_region" {}
variable "default_url_host" {}

variable "vpc_id" {}

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

variable "outbound_call_job_queue_url" {
  default     = ""
  description = "SQS Queue URL for outbound call worker"
}

variable "db_pool" {
  default = "32"
}

variable "instance_type" {
  description = "EC2 instance type"
  default     = "t2.micro"
}

variable "security_groups" {
  type = "list"
}

variable "outbound_call_drb_uri" {}

variable "database_url" {}

variable "rails_master_key" {}

variable "s3_access_key_id" {}

variable "s3_secret_access_key" {}

variable "uploads_bucket" {}

variable "asset_host" {
  default = ""
}

variable "ssl_certificate_id" {
  default = ""
}

variable "cloudwatch_enabled" {
  default = "true"
}

variable "cloudwatch_delete_on_terminate" {
  default = "false"
}

variable "cloudwatch_retention_in_days" {
  default = "30"
}
