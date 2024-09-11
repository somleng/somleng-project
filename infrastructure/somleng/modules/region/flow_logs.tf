data "aws_network_interface" "nat_gateway" {
  filter {
    name   = "association.allocation-id"
    values = module.vpc.nat_ids
  }
}

resource "aws_cloudwatch_log_group" "nat_gateway" {
  name              = "nat_gateway"
  retention_in_days = 7
}

resource "aws_flow_log" "nat_gateway" {
  iam_role_arn    = var.flow_logs_role.arn
  log_destination = aws_cloudwatch_log_group.nat_gateway.arn
  traffic_type    = "ALL"
  eni_id          = data.aws_network_interface.nat_gateway.id
  tags = {
    Name = "NAT Gateway"
  }
}
