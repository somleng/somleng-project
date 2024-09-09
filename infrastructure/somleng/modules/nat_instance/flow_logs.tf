resource "aws_iam_role" "flow_logs" {
  name = "${var.name}_flow_logs"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "vpc-flow-logs.amazonaws.com"
        }
      },
    ]
  })
}

resource "aws_iam_policy" "flow_logs" {
  name = "${var.name}_flow_logs"

  policy = jsonencode(
    {
      Version = "2012-10-17",
      Statement = [
        {
          Effect = "Allow",
          Action = [
            "logs:CreateLogGroup",
            "logs:CreateLogStream",
            "logs:PutLogEvents",
            "logs:DescribeLogGroups",
            "logs:DescribeLogStreams"
          ],
          Resource = aws_cloudwatch_log_group.this.arn
        }
      ]
    }
  )
}

resource "aws_iam_role_policy_attachment" "flow_logs" {
  role       = aws_iam_role.flow_logs.name
  policy_arn = aws_iam_policy.flow_logs.arn
}

resource "aws_flow_log" "this" {
  iam_role_arn    = aws_iam_role.flow_logs.arn
  log_destination = aws_cloudwatch_log_group.this.arn
  traffic_type    = "ALL"
  eni_id          = aws_network_interface.this.id
  tags = {
    Name = "NAT Instance"
  }
}
