resource "aws_eip" "freeswitch" {
  vpc = true

  tags {
    Name = "FreeSWITCH Public IP"
  }
}

resource "aws_eip_association" "freeswitch" {
  instance_id   = "${element(module.somleng_freeswitch_webserver.instances, 0)}"
  allocation_id = "${aws_eip.freeswitch.id}"
}

module "associate_eip" {
  source                            = "../modules/associate_eip"
  eip_allocation_id                 = "${aws_eip.freeswitch.id}"
  autoscaling_group                 = "${element(module.somleng_freeswitch_webserver.autoscaling_groups, 0)}"
  cloudwatch_event_rule_name        = "freeswitch-instance-terminated"
  cloudwatch_event_rule_description = "Runs when a FreeSWITCH instance is terminated by the autoscaling group"
}
