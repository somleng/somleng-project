locals {
  autoscaling_group = "${element(module.eb_env.autoscaling_groups, 0)}"
}

resource "aws_eip" "eip" {
  vpc = true

  tags {
    Name = "FreeSWITCH Public IP for ${var.env_identifier}"
  }
}

resource "aws_eip_association" "eip" {
  instance_id   = "${element(module.eb_env.instances, 0)}"
  allocation_id = "${aws_eip.eip.id}"
}

resource "aws_security_group" "sg" {
  name        = "${var.env_identifier}"
  description = "Whitelisted voice providers"
  vpc_id      = "${var.vpc_id}"

  tags {
    Name = "FreeSWITCH Security Group for ${var.env_identifier}"
  }
}

module "eb_solution_stack" {
  source = "../eb_solution_stacks"
}

module "eb_env" {
  source = "../eb_env"

  # General Settings
  app_name            = "${var.app_name}"
  solution_stack_name = "${module.eb_solution_stack.multi_container_docker_name}"
  env_identifier      = "${var.env_identifier}"
  tier                = "WebServer"

  tags = {
    "${var.eip_allocation_id_tag_key}" = "${aws_eip.eip.id}"
  }

  # VPC
  vpc_id                      = "${var.vpc_id}"
  elb_subnets                 = "${var.elb_subnets}"
  ec2_subnets                 = "${var.ec2_subnets}"
  elb_scheme                  = "${var.elb_scheme}"
  associate_public_ip_address = "${var.associate_public_ip_address}"

  # EC2 Settings
  instance_type     = "${var.instance_type}"
  ec2_instance_role = "${var.ec2_instance_role}"
  security_groups   = ["${aws_security_group.sg.id}"]

  # Elastic Beanstalk Environment
  service_role       = "${var.eb_service_role}"
  load_balancer_type = "${var.load_balancer_type}"

  # Listener
  default_listener_enabled = "${var.default_listener_enabled}"
  ssl_listener_enabled     = "${var.ssl_listener_enabled}"

  xmpp_listener_enabled = "${var.xmpp_listener_enabled}"
  xmpp_listener_port    = "${var.xmpp_port}"

  # Default Process
  default_process_protocol = "${var.default_process_protocol}"
  default_process_port     = "${var.xmpp_port}"

  # Autoscaling
  autoscaling_group_max_size = "${var.autoscaling_group_max_size}"

  # ENV Vars
  ## Defaults
  aws_region = "${var.aws_region}"

  # FreeSWITCH Specific

  freeswitch_app            = "true"
  fs_simulator              = "${var.simulator}"
  fs_external_ip            = "${aws_eip.eip.public_ip}"
  fs_mod_rayo_port          = "${var.xmpp_port}"
  fs_mod_rayo_domain_name   = "${var.mod_rayo_domain_name}"
  fs_mod_rayo_user          = "${var.mod_rayo_user}"
  fs_mod_rayo_password      = "${var.mod_rayo_password}"
  fs_mod_rayo_shared_secret = "${var.mod_rayo_shared_secret}"
  fs_mod_json_cdr_url       = "${var.mod_json_cdr_url}"
  fs_mod_json_cdr_cred      = "${var.mod_json_cdr_cred}"
}

resource "aws_autoscaling_lifecycle_hook" "terminate_instance" {
  name                   = "terminate-instance-hook"
  autoscaling_group_name = "${local.autoscaling_group}"
  default_result         = "CONTINUE"
  heartbeat_timeout      = 120
  lifecycle_transition   = "autoscaling:EC2_INSTANCE_TERMINATING"
}

resource "aws_cloudwatch_event_rule" "terminate_instance" {
  name        = "${var.env_identifier}-associate-eip"
  description = "Associate Elastic IP"

  event_pattern = <<PATTERN
{
  "source": [
    "aws.autoscaling"
  ],
  "detail-type": [
    "${var.associate_eip_event_detail_type}"
  ],
  "detail": {
    "AutoScalingGroupName": [
      "${local.autoscaling_group}"
    ]
  }
}
PATTERN
}

resource "aws_cloudwatch_event_target" "lambda" {
  rule = "${aws_cloudwatch_event_rule.terminate_instance.name}"
  arn  = "${var.associate_eip_lambda_arn}"
}

module "deploy" {
  source = "../deploy"

  eb_env_id    = "${module.eb_env.id}"
  repo         = "${var.deploy_repo}"
  branch       = "${var.deploy_branch}"
  travis_token = "${var.travis_token}"
}
