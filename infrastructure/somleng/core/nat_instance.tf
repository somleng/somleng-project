# Adapted from: https://github.com/int128/terraform-aws-nat-instance

locals {
  nat_instance_name = "nat-instance"
}

data "aws_subnet" "nat_instance" {
  id = aws_network_interface.nat_instance.subnet_id
}

# https://aws.amazon.com/ec2/instance-types/t4/
data "aws_ssm_parameter" "nat_instance" {
  name = "/aws/service/ami-amazon-linux-latest/al2023-ami-kernel-default-arm64"
}

resource "aws_eip" "nat_instance" {
  domain      = "vpc"

  tags = {
    Name = "NAT Instance"
  }
}

resource "aws_eip_association" "nat_instance" {
  network_interface_id = aws_network_interface.nat_instance.id
  allocation_id = aws_eip.nat_instance.id
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

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "ec2:AttachNetworkInterface"
      ],
      "Resource": "*"
    },
    {
      "Effect": "Allow",
      "Action": [
        "cloudwatch:PutMetricAlarm",
        "cloudwatch:DescribeAlarms"
      ],
      "Resource": [
        "${aws_cloudwatch_metric_alarm.nat_instance_network_out.arn}"
      ]
    }
  ]
}
EOF
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
  subnet_id       = module.vpc.public_subnets[0]
  description = "NAT Instance"
  security_groups = [aws_security_group.nat_instance.id]
  source_dest_check = false

  tags = {
    Name = "NAT Instance"
  }

  lifecycle {
    ignore_changes = [attachment]
  }
}

resource "aws_launch_template" "nat_instance" {
  name_prefix                 = "nat-instance"
  image_id                    = data.aws_ssm_parameter.nat_instance.value
  instance_type               = "t4g.small"

  iam_instance_profile {
    name = aws_iam_instance_profile.nat_instance.name
  }

  network_interfaces {
    associate_public_ip_address  = true
    security_groups = [aws_security_group.nat_instance.id]
  }

  user_data = base64encode(join("\n", [
    "#cloud-config",
    yamlencode({
      # https://cloudinit.readthedocs.io/en/latest/topics/modules.html
      write_files : [
        {
          path : "/opt/nat/setup.sh",
          content : templatefile("${path.module}/templates/nat_instance/setup.sh", { eni_id = aws_network_interface.nat_instance.id, cloudwatch_alarm_name = aws_cloudwatch_metric_alarm.nat_instance_network_out.alarm_name }),
          permissions : "0755",
        },
        {
          path : "/opt/nat/snat.sh",
          content : file("${path.module}/templates/nat_instance/snat.sh"),
          permissions : "0755",
        },
        {
          path : "/etc/systemd/system/snat.service",
          content : file("${path.module}/templates/nat_instance/snat.service"),
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
  cidr_blocks = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "nat_instance_ingress" {
  type              = "ingress"
  to_port           = 0
  protocol          = "-1"
  from_port         = 0
  security_group_id = aws_security_group.nat_instance.id
  cidr_blocks = module.vpc.private_subnets_cidr_blocks
}

resource "aws_autoscaling_group" "nat_instance" {
  name                 = "nat-instance"

  launch_template {
    id      = aws_launch_template.nat_instance.id
    version = aws_launch_template.nat_instance.latest_version
  }

  vpc_zone_identifier = [data.aws_subnet.nat_instance.id]
  max_size             = 2
  min_size             = 1
  desired_capacity     = 1
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
      min_healthy_percentage = 50
    }
    triggers = ["tag"]
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

# This is a per instance alarm
# this instance-id is updated by the init script

resource "aws_cloudwatch_metric_alarm" "nat_instance_network_out" {
  alarm_name          = "${local.nat_instance_name}-NetworkOut-Zero"
  comparison_operator = "LessThanOrEqualToThreshold"
  evaluation_periods  = "3"
  metric_name         = "NetworkPacketsOut"
  namespace           = "AWS/EC2"
  period              = "300"
  statistic           = "Average"
  threshold           = 0

  lifecycle {
    ignore_changes = [dimensions, alarm_actions]
  }
}

# Routes that need to use the NAT Instance

resource "aws_route" "zamtel" {
  route_table_id            = module.vpc.private_route_table_ids[0]
  destination_cidr_block    = "165.57.32.1/32"
  network_interface_id      = aws_network_interface.nat_instance.id
}

resource "aws_route" "zamtel_media" {
  route_table_id            = module.vpc.private_route_table_ids[0]
  destination_cidr_block    = "165.57.33.2/32"
  network_interface_id      = aws_network_interface.nat_instance.id
}

resource "aws_route" "telecom_cambodia_signalling" {
  route_table_id            = module.vpc.private_route_table_ids[0]
  destination_cidr_block    = "203.223.42.142/32"
  network_interface_id      = aws_network_interface.nat_instance.id
}

resource "aws_route" "telecom_cambodia_media" {
  route_table_id            = module.vpc.private_route_table_ids[0]
  destination_cidr_block    = "203.223.42.132/32"
  network_interface_id      = aws_network_interface.nat_instance.id
}

resource "aws_route" "telecom_cambodia_media2" {
  route_table_id            = module.vpc.private_route_table_ids[0]
  destination_cidr_block    = "203.223.42.148/32"
  network_interface_id      = aws_network_interface.nat_instance.id
}
