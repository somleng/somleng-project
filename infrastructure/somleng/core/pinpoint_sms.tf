
resource "aws_cloudwatch_log_group" "pinpoint_sms" {
  name = "somleng-pinpoint-sms"
  retention_in_days = 7
}

resource "aws_iam_role" "pinpoint_sms_cloudwatch" {
  name = "somleng-pinpoint-sms-cloudwatch"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "sms-voice.amazonaws.com"
        }
        Condition = {
          StringEquals = {
            "aws:SourceAccount": data.aws_caller_identity.current.account_id
          }
        }
      },
    ]
  })
}

resource "aws_iam_policy" "pinpoint_sms_cloudwatch" {
  name        = "somleng-pinpoint-sms-cloudwatch"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "logs:CreateLogStream",
          "logs:DescribeLogStreams",
          "logs:PutLogEvents"
        ]
        Effect   = "Allow"
        Resource = [
          aws_cloudwatch_log_group.pinpoint_sms.arn
        ]
      },
    ]
  })
}

resource "aws_iam_role_policy_attachment" "pinpoint_sms_cloudwatch" {
  role = aws_iam_role.pinpoint_sms_cloudwatch.name
  policy_arn = aws_iam_policy.pinpoint_sms_cloudwatch.arn
}
