resource "aws_security_group" "freeswitch" {
  name        = "${local.somleng_freeswitch_identifier}"
  description = "Whitelisted voice providers"
  vpc_id      = "${module.vpc.vpc_id}"

  tags {
    Name = "FreeSWITCH Security Group"
  }
}

resource "aws_security_group_rule" "telesom" {
  type        = "ingress"
  from_port   = 5060
  to_port     = 5060
  protocol    = "udp"
  cidr_blocks = ["196.201.207.191/32"]
  description = "Telesom"

  security_group_id = "${aws_security_group.freeswitch.id}"
}

resource "aws_security_group_rule" "mundivox" {
  type        = "ingress"
  from_port   = 5060
  to_port     = 5060
  protocol    = "udp"
  cidr_blocks = ["187.102.153.186/32"]
  description = "Mundivox"

  security_group_id = "${aws_security_group.freeswitch.id}"
}

resource "aws_security_group_rule" "mundivox_prod" {
  type        = "ingress"
  from_port   = 5060
  to_port     = 5060
  protocol    = "udp"
  cidr_blocks = ["200.142.96.52/32"]
  description = "Mundivox Production"

  security_group_id = "${aws_security_group.freeswitch.id}"
}

resource "aws_security_group_rule" "africell" {
  type        = "ingress"
  from_port   = 5060
  to_port     = 5060
  protocol    = "udp"
  cidr_blocks = ["41.223.132.58/32"]
  description = "Africell"

  security_group_id = "${aws_security_group.freeswitch.id}"
}

resource "aws_security_group_rule" "equinix" {
  type        = "ingress"
  from_port   = 5060
  to_port     = 5060
  protocol    = "udp"
  cidr_blocks = ["200.155.77.116/32"]
  description = "Equinix"

  security_group_id = "${aws_security_group.freeswitch.id}"
}
