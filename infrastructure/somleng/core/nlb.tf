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

resource "aws_lb" "somleng_network" {
  name = "somleng-network"
  load_balancer_type = "network"
  subnets = module.vpc.public_subnets
  enable_cross_zone_load_balancing = true

  access_logs {
    bucket  = aws_s3_bucket.logs.id
    prefix  = "somleng-network"
    enabled = true
  }
}

resource "aws_lb_target_group" "freeswitch" {
  name        = "freeswitch"
  port        = 5222
  protocol    = "TCP"
  target_type = "ip"
  vpc_id      = module.vpc.vpc_id
}

resource "aws_lb_target_group_attachment" "freeswitch_old" {
  count = length(data.aws_network_interface.freeswitch_old_load_balancer.*.private_ip)

  target_group_arn  = aws_lb_target_group.freeswitch.arn
  target_id = data.aws_network_interface.freeswitch_old_load_balancer.*.private_ip[count.index]
  availability_zone = "all"
}

resource "aws_lb_listener" "xmpp" {
  load_balancer_arn = aws_lb.somleng_network.arn
  port              = "5222"
  protocol          = "TCP"

  default_action {
    type = "forward"
    target_group_arn = aws_lb_target_group.freeswitch.arn
  }
}