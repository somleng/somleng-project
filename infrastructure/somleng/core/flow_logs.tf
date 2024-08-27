data "aws_network_interface" "nat_gateway" {
  filter {
    name   = "association.allocation-id"
    values = module.hydrogen_region.vpc.nat_ids
  }
}

resource "aws_cloudwatch_log_group" "nat_gateway" {
  name              = "nat_gateway"
  retention_in_days = 7
}

resource "aws_flow_log" "nat_gateway" {
  iam_role_arn    = aws_iam_role.flow_logs.arn
  log_destination = aws_cloudwatch_log_group.nat_gateway.arn
  traffic_type    = "ALL"
  eni_id          = data.aws_network_interface.nat_gateway.id
  tags = {
    Name = "NAT Gateway"
  }
}

resource "aws_iam_role" "flow_logs" {
  name = "flow_logs"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "",
      "Effect": "Allow",
      "Principal": {
        "Service": "vpc-flow-logs.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "flow_logs" {
  name = "flow_logs"
  role = aws_iam_role.flow_logs.id

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents",
        "logs:DescribeLogGroups",
        "logs:DescribeLogStreams"
      ],
      "Effect": "Allow",
      "Resource": "*"
    }
  ]
}
EOF
}
