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
