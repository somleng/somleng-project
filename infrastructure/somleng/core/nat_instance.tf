locals {
  nat_instance_name = "nat-instance"
}

# https://aws.amazon.com/ec2/instance-types/t4/
data "aws_ssm_parameter" "nat_instance_arm64" {
  name = "/aws/service/ami-amazon-linux-latest/amzn2-ami-hvm-arm64-gp2"
}

data "aws_ssm_parameter" "nat_instance" {
  name = "/aws/service/ami-amazon-linux-latest/amzn2-ami-hvm-x86_64-gp2"
}

resource "aws_eip" "nat_instance" {
  vpc      = true

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

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "ec2:DescribeTags",
        "ec2:AssociateAddress",
        "sts:DecodeAuthorizationMessage"
      ],
      "Resource": "*"
    },
    {
      "Effect": "Allow",
      "Action": [
        "ec2:ModifyInstanceAttribute"
      ],
      "Resource": "*",
      "Condition": {
        "StringEquals": {
          "ec2:ResourceTag/Name": "${local.nat_instance_name}"
        }
      }
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

resource "aws_launch_configuration" "nat_instance" {
  name_prefix                 = "nat-instance"
  image_id                    = data.aws_ssm_parameter.nat_instance_arm64.value
  instance_type               = "t4g.small"
  iam_instance_profile        = aws_iam_instance_profile.nat_instance.name
  security_groups             = [aws_security_group.nat_instance.id]
  user_data                   = data.template_file.nat_instance_user_data.rendered
  associate_public_ip_address = false # use EIP

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
  launch_configuration = aws_launch_configuration.nat_instance.name
  vpc_zone_identifier  = module.vpc.public_subnets
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

  tag {
    key                 = "EipAllocationId"
    value               = aws_eip.nat_instance.id
    propagate_at_launch = true
  }

  lifecycle {
    create_before_destroy = true
  }
}

data "template_file" "nat_instance_user_data" {
  template = file("${path.module}/templates/nat_instance_user_data.sh")
}
