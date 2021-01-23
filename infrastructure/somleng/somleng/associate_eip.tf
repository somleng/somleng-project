locals {
  lambda_runtime            = "python2.7"
  lambda_function_name      = "associate_eip"
  lambda_handler            = "${local.lambda_function_name}.lambda_handler"
  path_to_lambda_source     = "${path.module}/lambda/associate_eip.py"
  path_to_lambda_archive    = "${path.module}/lambda/associate_eip.zip"
  event_detail_type         = "EC2 Instance-terminate Lifecycle Action"
}

resource "aws_iam_role" "lambda_associate_eip" {
  name = "lambda-associate-eip"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "lambda_associate_eip" {
  name = "lambda-associate-eip-policy"
  role = aws_iam_role.lambda_associate_eip.id

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents"
      ],
      "Effect": "Allow",
      "Resource": "arn:aws:logs:*:*:*"
    },
    {
      "Action": [
        "ec2:AssociateAddress",
        "ec2:DescribeAddresses",
        "ec2:DescribeInstances",
        "autoscaling:DescribeAutoScalingGroups",
        "autoscaling:CompleteLifecycleAction",
        "elasticloadbalancing:RegisterTargets"
      ],
      "Effect": "Allow",
      "Resource": "*"
    }
  ]
}
EOF
}

resource "aws_lambda_function" "associate_eip" {
  filename         = local.path_to_lambda_archive
  function_name    = local.lambda_function_name
  runtime          = local.lambda_runtime
  handler          = local.lambda_handler
  role             = aws_iam_role.lambda_associate_eip.arn
  source_code_hash = data.archive_file.associate_eip_source_code.output_base64sha256

  lifecycle {
    ignore_changes = [filename, last_modified]
  }

  environment {
    variables = {
      EVENT_DETAIL_TYPE         = local.event_detail_type
      EIP_ALLOCATION_ID_TAG_KEY = "eip_allocation_id"
      TARGET_GROUP_ARN_TAG_KEY = "sip_target_group_arn"
    }
  }
}

data "archive_file" "associate_eip_source_code" {
  type        = "zip"
  source_file = local.path_to_lambda_source
  output_path = local.path_to_lambda_archive
}

resource "aws_lambda_permission" "cloudwatch_events" {
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.associate_eip.function_name
  principal     = "events.amazonaws.com"
}
