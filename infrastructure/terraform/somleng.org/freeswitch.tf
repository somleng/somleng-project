module "freeswitch_simulator" {
  source = "../modules/freeswitch"

  app_name       = "${module.somleng_freeswitch_eb_app.app_name}"
  env_identifier = "${local.somleng_freeswitch_identifier}-simulator"

  vpc_id                          = "${module.vpc.vpc_id}"
  elb_subnets                     = "${module.vpc.intra_subnets}"
  ec2_subnets                     = "${module.vpc.public_subnets}"
  ec2_instance_role               = "${module.eb_iam.eb_ec2_instance_role}"
  eb_service_role                 = "${module.eb_iam.eb_service_role}"
  aws_region                      = "${var.aws_region}"
  xmpp_listener_enabled           = "false"
  associate_eip_event_detail_type = "${module.associate_eip.event_detail_type}"
  associate_eip_lambda_arn        = "${module.associate_eip.lambda_arn}"
}

resource "aws_security_group_rule" "freeswitch_main" {
  type        = "ingress"
  from_port   = 5060
  to_port     = 5060
  protocol    = "udp"
  cidr_blocks = ["${module.freeswitch_simulator.public_ip}/32"]
  description = "FreeSWITCH Main"

  security_group_id = "${aws_security_group.freeswitch.id}"
}
