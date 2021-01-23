data "aws_lb" "freeswitch_old_load_balancer" {
  name = "awseb-AWSEB-14GZZW6JCV7OE"
}

data "aws_network_interface" "freeswitch_old_load_balancer" {
  count = length(data.aws_lb.freeswitch_old_load_balancer.subnets)

  filter {
    name   = "description"
    values = ["ELB ${data.aws_lb.freeswitch_old_load_balancer.arn_suffix}"]
  }

  filter {
    name = "subnet-id"
    values = [tolist(data.aws_lb.freeswitch_old_load_balancer.subnets)[count.index]]
  }
}

resource "aws_eip" "nlb" {
  count = length(module.vpc.public_subnets)
  vpc = true

  tags = {
    Name = "NLB Public IP"
  }
}

resource "aws_lb" "somleng_network" {
  name = "somleng-network"
  load_balancer_type = "network"
  enable_cross_zone_load_balancing = true

  access_logs {
    bucket  = aws_s3_bucket.logs.id
    prefix  = "somleng-network"
    enabled = true
  }

  dynamic "subnet_mapping" {
    for_each = module.vpc.public_subnets
    content {
      subnet_id     = subnet_mapping.value
      allocation_id = aws_eip.nlb.*.id[subnet_mapping.key]
    }
  }
}

resource "aws_lb_target_group" "freeswitch_xmpp" {
  name        = "freeswitch-xmpp"
  port        = 5222
  protocol    = "TCP"
  target_type = "ip"
  vpc_id      = module.vpc.vpc_id
}

resource "aws_lb_target_group" "freeswitch_sip" {
  name        = "freeswitch-sip"
  port        = 5060
  protocol    = "UDP"
  target_type = "ip"
  vpc_id      = module.vpc.vpc_id

  health_check {
    port = 5222
    protocol = "TCP"
  }
}

resource "aws_lb_target_group_attachment" "freeswitch_old_xmpp" {
  count = length(data.aws_network_interface.freeswitch_old_load_balancer.*.private_ip)

  target_group_arn  = aws_lb_target_group.freeswitch_xmpp.arn
  target_id = data.aws_network_interface.freeswitch_old_load_balancer.*.private_ip[count.index]
  availability_zone = "all"
}

resource "aws_lb_target_group_attachment" "freeswitch_old_sip" {
  count = length(data.aws_network_interface.freeswitch_old_load_balancer.*.private_ip)

  target_group_arn  = aws_lb_target_group.freeswitch_sip.arn
  target_id = data.aws_network_interface.freeswitch_old_load_balancer.*.private_ip[count.index]
  availability_zone = "all"
}

resource "aws_lb_listener" "xmpp" {
  load_balancer_arn = aws_lb.somleng_network.arn
  port              = "5222"
  protocol          = "TCP"

  default_action {
    type = "forward"
    target_group_arn = aws_lb_target_group.freeswitch_xmpp.arn
  }
}

resource "aws_lb_listener" "sip" {
  load_balancer_arn = aws_lb.somleng_network.arn
  port              = "5060"
  protocol          = "UDP"

  default_action {
    type = "forward"
    target_group_arn = aws_lb_target_group.freeswitch_sip.arn
  }
}

