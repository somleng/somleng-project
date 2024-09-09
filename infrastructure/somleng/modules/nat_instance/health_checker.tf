## ECR

resource "aws_ecr_repository" "health_checker" {
  name = var.health_checker_name

  image_scanning_configuration {
    scan_on_push = true
  }
}

## Docker image

resource "docker_image" "health_checker" {
  name = "${aws_ecr_repository.health_checker.repository_url}:latest"
  build {
    context = abspath("${path.module}/health_checker")
  }

  triggers = {
    dir_sha1 = sha1(join("", [for f in fileset("", "${path.module}/health_checker/**") : filesha1(f)]))
  }
}

resource "docker_registry_image" "nat_instance_health_checker" {
  name          = docker_image.health_checker.name
  keep_remotely = true
  triggers = {
    image_id = docker_image.health_checker.image_id
  }
}

# IAM
resource "aws_iam_role" "health_checker" {
  name = var.health_checker_name

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      },
    ]
  })
}

resource "aws_iam_role_policy_attachment" "health_checker_vpc_access_execution_role" {
  role       = aws_iam_role.health_checker.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaVPCAccessExecutionRole"
}

resource "aws_iam_policy" "health_checker_custom_policy" {
  name = var.health_checker_name

  policy = jsonencode(
    {
      Version = "2012-10-17",
      Statement = [
        {
          Action = [
            "cloudwatch:PutMetricData"
          ]
          Effect   = "Allow"
          Resource = "*",
          Condition = {
            StringEquals = {
              "cloudwatch:namespace" = "NatInstance"
            }
          }
        },
        {
          Action = [
            "ec2:DescribeNetworkInterfaceAttribute"
          ]
          Effect   = "Allow"
          Resource = "*"
        },
        {
          Action = [
            "autoscaling:SetInstanceHealth"
          ]
          Effect   = "Allow"
          Resource = aws_autoscaling_group.this.arn
        },
      ]
    }
  )
}

resource "aws_iam_role_policy_attachment" "health_checker_custom_policy" {
  role       = aws_iam_role.health_checker.name
  policy_arn = aws_iam_policy.health_checker_custom_policy.arn
}

# Security Group

resource "aws_security_group" "health_checker" {
  name   = var.health_checker_name
  vpc_id = var.vpc.vpc_id

  tags = {
    "Name" = "NAT Instance Health Checker"
  }
}

resource "aws_security_group_rule" "health_checker_egress" {
  type              = "egress"
  to_port           = 0
  protocol          = "-1"
  from_port         = 0
  security_group_id = aws_security_group.health_checker.id
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_cloudwatch_log_group" "health_checker" {
  name              = "/aws/lambda/nat-instance-health-checker"
  retention_in_days = 7
}

# Lambda Function

resource "aws_lambda_function" "health_checker" {
  function_name    = var.health_checker_name
  role             = aws_iam_role.health_checker.arn
  package_type     = "Image"
  architectures    = ["arm64"]
  image_uri        = docker_registry_image.nat_instance_health_checker.name
  timeout          = 300
  memory_size      = 512
  source_code_hash = docker_registry_image.nat_instance_health_checker.sha256_digest

  vpc_config {
    security_group_ids = [aws_security_group.health_checker.id]
    subnet_ids         = var.vpc.private_subnets
  }

  environment {
    variables = {
      NAT_INSTANCE_ENI_ID         = aws_network_interface.this.id
      CLOUDWATCH_METRIC_NAMESPACE = "NatInstance"
      CLOUDWATCH_METRIC_NAME      = "NatInstanceHealthyRoutes"
      NAT_INSTANCE_IP             = aws_eip.this.public_ip
    }
  }

  depends_on = [
    aws_cloudwatch_log_group.health_checker,
    docker_registry_image.nat_instance_health_checker,
    aws_route.health_check_target
  ]
}

# CloudWatch Event Rule

resource "aws_cloudwatch_event_rule" "health_checker" {
  name                = var.health_checker_name
  schedule_expression = "rate(1 minute)"
}

resource "aws_lambda_permission" "health_checker" {
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.health_checker.arn
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.health_checker.arn
}

resource "aws_cloudwatch_event_target" "health_checker" {
  target_id = aws_cloudwatch_event_rule.health_checker.name
  arn       = aws_lambda_function.health_checker.arn
  rule      = aws_cloudwatch_event_rule.health_checker.name
}

# Metric Alarm

resource "aws_cloudwatch_metric_alarm" "health_checker" {
  alarm_name          = var.health_checker_name
  comparison_operator = "LessThanOrEqualToThreshold"
  evaluation_periods  = 2
  metric_name         = aws_lambda_function.health_checker.environment[0].variables.CLOUDWATCH_METRIC_NAME
  namespace           = aws_lambda_function.health_checker.environment[0].variables.CLOUDWATCH_METRIC_NAMESPACE
  period              = 120
  statistic           = "Average"
  threshold           = 0
  alarm_description   = "A value of 0 indicates that the NAT instance is unhealthy"
  alarm_actions       = [aws_lambda_function.health_checker.arn]

  dimensions = {
    EniId = aws_network_interface.this.id
  }

  treat_missing_data = "breaching"
}

# Lambda permission

resource "aws_lambda_permission" "health_checker_alarm" {
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.health_checker.arn
  principal     = "lambda.alarms.cloudwatch.amazonaws.com"
  source_arn    = aws_cloudwatch_metric_alarm.health_checker.arn
}
