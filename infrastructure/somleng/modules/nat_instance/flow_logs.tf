resource "aws_flow_log" "this" {
  iam_role_arn    = var.flow_logs_role.arn
  log_destination = aws_cloudwatch_log_group.this.arn
  traffic_type    = "ALL"
  eni_id          = aws_network_interface.this.id
  tags = {
    Name = "NAT Instance"
  }
}
