variable "app_name" {}
variable "env_identifier" {}
variable "vpc_id" {}

variable "elb_subnets" {
  type = "list"
}

variable "ec2_subnets" {
  type = "list"
}

variable "aws_region" {}
variable "ec2_instance_role" {}
variable "eb_service_role" {}
variable "associate_eip_event_detail_type" {}
variable "associate_eip_lambda_arn" {}

variable "elb_scheme" {
  default = "internal"
}

variable "associate_public_ip_address" {
  default = "true"
}

variable "instance_type" {
  default = "t2.micro"
}

variable "load_balancer_type" {
  default = "network"
}

variable "default_listener_enabled" {
  default = "false"
}

variable "ssl_listener_enabled" {
  default = "false"
}

variable "xmpp_listener_enabled" {
  default = "true"
}

variable "xmpp_port" {
  default = "5222"
}

variable "default_process_protocol" {
  default = "TCP"
}

variable "autoscaling_group_max_size" {
  default = "1"
}

variable "mod_rayo_domain_name" {
  default = ""
}

variable "mod_rayo_user" {
  default = ""
}

variable "mod_rayo_password" {
  default = ""
}

variable "mod_rayo_shared_secret" {
  default = ""
}

variable "mod_json_cdr_url" {
  default = ""
}

variable "mod_json_cdr_cred" {
  default = ""
}
