resource "aws_security_group_rule" "freeswitch_main" {
  type        = "ingress"
  from_port   = 5060
  to_port     = 5060
  protocol    = "udp"
  cidr_blocks = ["${module.freeswitch_main.public_ip}/32"]
  description = "FreeSWITCH Main"

  security_group_id = "${module.freeswitch_simulator.security_group_id}"
}

resource "aws_security_group_rule" "orange_sierra_leone" {
  type        = "ingress"
  from_port   = 5060
  to_port     = 5060
  protocol    = "udp"
  cidr_blocks = ["197.215.105.30/32"]
  description = "Orange Sierra Leone"

  security_group_id = "${module.freeswitch_main.security_group_id}"
}

resource "aws_security_group_rule" "hormuud_somalia" {
  type        = "ingress"
  from_port   = 5060
  to_port     = 5060
  protocol    = "udp"
  cidr_blocks = ["41.78.73.242/32"]
  description = "Hormuud Somalia"

  security_group_id = "${module.freeswitch_main.security_group_id}"
}

resource "aws_security_group_rule" "smart_cambodia" {
  type        = "ingress"
  from_port   = 5060
  to_port     = 5060
  protocol    = "udp"
  cidr_blocks = ["27.109.112.80/32"]
  description = "Smart Cambodia"

  security_group_id = "${module.freeswitch_main.security_group_id}"
}

resource "aws_security_group_rule" "cellcard_cambodia" {
  type        = "ingress"
  from_port   = 5060
  to_port     = 5060
  protocol    = "udp"
  cidr_blocks = ["103.193.204.17/32"]
  description = "Cellcard Cambodia"

  security_group_id = "${module.freeswitch_main.security_group_id}"
}

resource "aws_security_group_rule" "metfone_cambodia" {
  type        = "ingress"
  from_port   = 5060
  to_port     = 5060
  protocol    = "udp"
  cidr_blocks = ["175.100.32.29/32"]
  description = "Metfone Cambodia"

  security_group_id = "${module.freeswitch_main.security_group_id}"
}
