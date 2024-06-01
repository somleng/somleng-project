# Adapted from:
# https://github.com/int128/terraform-aws-nat-instance
# https://pabis.eu/blog/2023-06-11-NAT-Instance-on-AWS-from-scratch.html
# https://github.com/int128/terraform-aws-nat-instance/issues/65

locals {
  nat_instance_name                = "nat-instance"
  nat_instance_health_checker_name = "nat-instance-health-checker"
}

data "aws_subnet" "nat_instance" {
  id = aws_network_interface.nat_instance.subnet_id
}

# https://aws.amazon.com/ec2/instance-types/t4/
data "aws_ssm_parameter" "nat_instance" {
  name = "/aws/service/ami-amazon-linux-latest/al2023-ami-kernel-default-arm64"
}

resource "aws_eip" "nat_instance" {
  domain = "vpc"

  tags = {
    Name = "NAT Instance"
  }
}

resource "aws_iam_role" "nat_instance" {
  name = "nat_instance_role"

  assume_role_policy = <<EOF
{
  "Version": "2008-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": ["ec2.amazonaws.com"]
      },
      "Effect": "Allow"
    }
  ]
}
EOF
}

resource "aws_iam_instance_profile" "nat_instance" {
  name = "nat_instance_profile"
  role = aws_iam_role.nat_instance.name
}

resource "aws_iam_policy" "nat_instance_policy" {
  name = "nat-instance-policy"

  policy = jsonencode(
    {
      Version = "2012-10-17",
      Statement = [
        {
          Effect = "Allow",
          Action = [
            "ec2:AttachNetworkInterface",
            "ec2:AssociateAddress",
            "ec2:ModifyInstanceAttribute"
          ],
          Resource = "*"
        }
      ]
    }
  )
}

resource "aws_iam_role_policy_attachment" "nat_instance" {
  role       = aws_iam_role.nat_instance.name
  policy_arn = aws_iam_policy.nat_instance_policy.arn
}

resource "aws_iam_role_policy_attachment" "nat_instance_ssm" {
  role       = aws_iam_role.nat_instance.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_network_interface" "nat_instance" {
  subnet_id         = module.vpc.public_subnets[0]
  description       = "NAT Instance"
  security_groups   = [aws_security_group.nat_instance.id]
  source_dest_check = false

  tags = {
    Name = "NAT Instance"
  }

  lifecycle {
    ignore_changes = [attachment]
  }
}

resource "aws_launch_template" "nat_instance" {
  name_prefix   = "nat-instance"
  image_id      = data.aws_ssm_parameter.nat_instance.value
  instance_type = "t4g.small"

  iam_instance_profile {
    name = aws_iam_instance_profile.nat_instance.name
  }

  network_interfaces {
    associate_public_ip_address = true
    security_groups             = [aws_security_group.nat_instance.id]
  }

  user_data = base64encode(join("\n", [
    "#cloud-config",
    yamlencode({
      # https://cloudinit.readthedocs.io/en/latest/topics/modules.html
      write_files : [
        {
          path : "/opt/nat/setup.sh",
          content : templatefile(
            "${path.module}/nat_instance/templates/setup.sh",
            {
              eni_id            = aws_network_interface.nat_instance.id,
              eip_allocation_id = aws_eip.nat_instance.id
            }
          ),
          permissions : "0755",
        },
        {
          path : "/opt/nat/snat.sh",
          content : file("${path.module}/nat_instance/templates/snat.sh"),
          permissions : "0755",
        },
        {
          path : "/etc/systemd/system/snat.service",
          content : file("${path.module}/nat_instance/templates/snat.service"),
        },
      ],
      runcmd : [
        ["/opt/nat/setup.sh"]
      ],
    })
  ]))

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_security_group" "nat_instance" {
  name   = "nat-instance"
  vpc_id = module.vpc.vpc_id
}

# https://docs.aws.amazon.com/vpc/latest/userguide/VPC_NAT_Instance.html#NATSG
resource "aws_security_group_rule" "nat_instance_egress" {
  type              = "egress"
  to_port           = 0
  protocol          = "-1"
  from_port         = 0
  security_group_id = aws_security_group.nat_instance.id
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "nat_instance_ingress" {
  type              = "ingress"
  to_port           = 0
  protocol          = "-1"
  from_port         = 0
  security_group_id = aws_security_group.nat_instance.id
  cidr_blocks       = module.vpc.private_subnets_cidr_blocks
}

resource "aws_autoscaling_group" "nat_instance" {
  name = "nat-instance"

  launch_template {
    id      = aws_launch_template.nat_instance.id
    version = aws_launch_template.nat_instance.latest_version
  }

  vpc_zone_identifier       = [data.aws_subnet.nat_instance.id]
  max_size                  = 2
  min_size                  = 1
  desired_capacity          = 1
  wait_for_capacity_timeout = 0

  termination_policies = ["OldestInstance"]

  tag {
    key                 = "Name"
    value               = local.nat_instance_name
    propagate_at_launch = true
  }

  instance_refresh {
    strategy = "Rolling"
    preferences {
      min_healthy_percentage = 0
    }
    triggers = ["tag"]
  }

  instance_maintenance_policy {
    min_healthy_percentage = 0
    max_healthy_percentage = 100
  }

  lifecycle {
    create_before_destroy = true
  }
}


# Automatically update the SSM agent

# https://docs.aws.amazon.com/systems-manager/latest/userguide/sysman-state-cli.html
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ssm_association
resource "aws_ssm_association" "update_ssm_agent" {
  name = "AWS-UpdateSSMAgent"

  targets {
    key    = "tag:Name"
    values = [local.nat_instance_name]
  }

  schedule_expression = "cron(0 19 ? * SAT *)"
}

# Routes that need to use the NAT Instance

resource "aws_route" "zamtel" {
  route_table_id         = module.vpc.private_route_table_ids[0]
  destination_cidr_block = "165.57.32.1/32"
  network_interface_id   = aws_network_interface.nat_instance.id
}

resource "aws_route" "zamtel_media" {
  route_table_id         = module.vpc.private_route_table_ids[0]
  destination_cidr_block = "165.57.33.2/32"
  network_interface_id   = aws_network_interface.nat_instance.id
}

resource "aws_route" "telecom_cambodia_signaling" {
  route_table_id         = module.vpc.private_route_table_ids[0]
  destination_cidr_block = "203.223.42.142/32"
  network_interface_id   = aws_network_interface.nat_instance.id
}

resource "aws_route" "telecom_cambodia_media" {
  route_table_id         = module.vpc.private_route_table_ids[0]
  destination_cidr_block = "203.223.42.132/32"
  network_interface_id   = aws_network_interface.nat_instance.id
}

resource "aws_route" "telecom_cambodia_media2" {
  route_table_id         = module.vpc.private_route_table_ids[0]
  destination_cidr_block = "203.223.42.148/32"
  network_interface_id   = aws_network_interface.nat_instance.id
}

resource "aws_route" "health_check_target" {
  route_table_id         = module.vpc.private_route_table_ids[0]
  destination_cidr_block = "54.169.198.37/32"
  network_interface_id   = aws_network_interface.nat_instance.id
}

# Flow logs

resource "aws_flow_log" "nat_instance" {
  iam_role_arn    = aws_iam_role.flow_logs.arn
  log_destination = aws_cloudwatch_log_group.nat_instance.arn
  traffic_type    = "ALL"
  eni_id          = aws_network_interface.nat_instance.id
  tags = {
    Name = "NAT Instance"
  }
}

resource "aws_cloudwatch_log_group" "nat_instance" {
  name = "nat_instance"
}

# Health Checker

## ECR

resource "aws_ecr_repository" "nat_instance_health_checker" {
  name = local.nat_instance_health_checker_name

  image_scanning_configuration {
    scan_on_push = true
  }
}

data "aws_ecr_authorization_token" "nat_instance_health_checker" {
  registry_id = aws_ecr_repository.nat_instance_health_checker.registry_id
}

## Docker image

provider "docker" {
  registry_auth {
    address  = data.aws_ecr_authorization_token.nat_instance_health_checker.proxy_endpoint
    username = data.aws_ecr_authorization_token.nat_instance_health_checker.user_name
    password = data.aws_ecr_authorization_token.nat_instance_health_checker.password
  }
}

resource "docker_image" "nat_instance_health_checker" {
  name = "${aws_ecr_repository.nat_instance_health_checker.repository_url}:latest"
  build {
    context = abspath("${path.module}/nat_instance/health_checker")
  }

  triggers = {
    dir_sha1 = sha1(join("", [for f in fileset(path.module, "nat_instance/health_checker/**") : filesha1(f)]))
  }
}

resource "docker_registry_image" "nat_instance_health_checker" {
  name          = docker_image.nat_instance_health_checker.name
  keep_remotely = true
  triggers = {
    image_id = docker_image.nat_instance_health_checker.image_id
  }
}

# IAM
resource "aws_iam_role" "nat_instance_health_checker" {
  name               = local.nat_instance_health_checker_name
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

resource "aws_iam_role_policy_attachment" "nat_instance_health_checker_vpc_access_execution_role" {
  role       = aws_iam_role.nat_instance_health_checker.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaVPCAccessExecutionRole"
}

resource "aws_iam_policy" "nat_instance_health_checker_custom_policy" {
  name = local.nat_instance_health_checker_name

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
        }
      ]
    }
  )
}

resource "aws_iam_role_policy_attachment" "nat_instance_health_checker_custom_policy" {
  role       = aws_iam_role.nat_instance_health_checker.name
  policy_arn = aws_iam_policy.nat_instance_health_checker_custom_policy.arn
}

# Security Group

resource "aws_security_group" "nat_instance_health_checker" {
  name   = local.nat_instance_health_checker_name
  vpc_id = module.vpc.vpc_id

  tags = {
    "Name" = "NAT Instance Health Checker"
  }
}

resource "aws_security_group_rule" "nat_instance_health_checker_egress" {
  type              = "egress"
  to_port           = 0
  protocol          = "-1"
  from_port         = 0
  security_group_id = aws_security_group.nat_instance_health_checker.id
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_cloudwatch_log_group" "nat_instance_health_checker" {
  name              = "/aws/lambda/nat-instance-health-checker"
  retention_in_days = 7
}

# Lambda Function

resource "aws_lambda_function" "nat_instance_health_checker" {
  function_name    = local.nat_instance_health_checker_name
  role             = aws_iam_role.nat_instance_health_checker.arn
  package_type     = "Image"
  architectures    = ["arm64"]
  image_uri        = docker_registry_image.nat_instance_health_checker.name
  timeout          = 300
  memory_size      = 512
  source_code_hash = docker_registry_image.nat_instance_health_checker.sha256_digest

  vpc_config {
    security_group_ids = [aws_security_group.nat_instance_health_checker.id]
    subnet_ids         = module.vpc.private_subnets
  }

  environment {
    variables = {
      NAT_INSTANCE_ENI_ID         = aws_network_interface.nat_instance.id
      CLOUDWATCH_METRIC_NAMESPACE = "NatInstance"
      HEALTH_CHECK_TARGET         = aws_route.health_check_target.destination_cidr_block
      NAT_INSTANCE_IP             = aws_eip.nat_instance.public_ip
    }
  }

  depends_on = [
    aws_cloudwatch_log_group.nat_instance_health_checker,
    docker_registry_image.nat_instance_health_checker
  ]
}

resource "aws_cloudwatch_event_rule" "nat_instance_health_checker" {
  name                = local.nat_instance_health_checker_name
  schedule_expression = "rate(1 minute)"
}

resource "aws_lambda_permission" "nat_instance_health_checker" {
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.nat_instance_health_checker.arn
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.nat_instance_health_checker.arn
}

resource "aws_cloudwatch_event_target" "nat_instance_health_checker" {
  target_id = aws_cloudwatch_event_rule.nat_instance_health_checker.name
  arn       = aws_lambda_function.nat_instance_health_checker.arn
  rule      = aws_cloudwatch_event_rule.nat_instance_health_checker.name
}
