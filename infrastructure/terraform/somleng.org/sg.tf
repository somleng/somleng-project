resource "aws_security_group_rule" "freeswitch_main" {
  type        = "ingress"
  from_port   = 5060
  to_port     = 5060
  protocol    = "udp"
  cidr_blocks = ["${module.freeswitch_main.public_ip}/32"]
  description = "FreeSWITCH Main"

  security_group_id = "${module.freeswitch_simulator.security_group_id}"
}

resource "aws_security_group_rule" "telesom" {
  type        = "ingress"
  from_port   = 5060
  to_port     = 5060
  protocol    = "udp"
  cidr_blocks = ["196.201.207.191/32"]
  description = "Telesom"

  security_group_id = "${module.freeswitch_main.security_group_id}"
}

resource "aws_security_group_rule" "mundivox" {
  type        = "ingress"
  from_port   = 5060
  to_port     = 5060
  protocol    = "udp"
  cidr_blocks = ["187.102.153.186/32"]
  description = "Mundivox"

  security_group_id = "${module.freeswitch_main.security_group_id}"
}

resource "aws_security_group_rule" "mundivox_prod" {
  type        = "ingress"
  from_port   = 5060
  to_port     = 5060
  protocol    = "udp"
  cidr_blocks = ["200.142.96.52/32"]
  description = "Mundivox Production"

  security_group_id = "${module.freeswitch_main.security_group_id}"
}

resource "aws_security_group_rule" "africell" {
  type        = "ingress"
  from_port   = 5060
  to_port     = 5060
  protocol    = "udp"
  cidr_blocks = ["41.223.132.58/32"]
  description = "Africell"

  security_group_id = "${module.freeswitch_main.security_group_id}"
}

resource "aws_security_group_rule" "equinix" {
  type        = "ingress"
  from_port   = 5060
  to_port     = 5060
  protocol    = "udp"
  cidr_blocks = ["200.155.77.116/32"]
  description = "Equinix"

  security_group_id = "${module.freeswitch_main.security_group_id}"
}
