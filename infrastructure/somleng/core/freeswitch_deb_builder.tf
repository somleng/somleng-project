data "aws_ami" "debian_latest" {
  most_recent = true
  name_regex  = "debian-11-arm64"
  owners      = ["136693071363"]

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

resource "aws_iam_role" "freeswitch_deb_builder" {
  name = "freeswitch_deb_builder"

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

resource "aws_iam_instance_profile" "freeswitch_deb_builder" {
  name = "freeswitch_deb_builder"
  role = aws_iam_role.freeswitch_deb_builder.name
}

resource "aws_iam_role_policy_attachment" "freeswitch_deb_builder_ssm" {
  role       = aws_iam_role.freeswitch_deb_builder.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_launch_template" "freeswitch_deb_builder" {
  name_prefix                 = "freeswitch-deb-builder"
  image_id                    = data.aws_ami.debian_latest.id
  instance_type               = "t4g.small"

  iam_instance_profile {
    name = aws_iam_instance_profile.freeswitch_deb_builder.name
  }

  vpc_security_group_ids = [aws_security_group.freeswitch_deb_builder.id]

  user_data = base64encode(join("\n", [
    "#cloud-config",
    yamlencode({
      write_files : [
        {
          path : "/opt/builder/build.sh",
          content : file("${path.module}/templates/freeswitch_deb_builder/build.sh"),
          permissions : "0755",
        },
        {
          path : "/opt/ssm_agent.sh",
          content : file("${path.module}/templates/freeswitch_deb_builder/ssm_agent.sh"),
          permissions : "0755",
        },
      ],
      runcmd : [
        ["/opt/ssm_agent.sh", "/opt/builder/build.sh"]
      ],
    })
  ]))

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_security_group" "freeswitch_deb_builder" {
  name   = "freeswitch-deb-builder"
  vpc_id = module.vpc.vpc_id
}

resource "aws_security_group_rule" "freeswitch_deb_builder_egress" {
  type              = "egress"
  to_port           = 0
  protocol          = "-1"
  from_port         = 0
  security_group_id = aws_security_group.freeswitch_deb_builder.id
  cidr_blocks = ["0.0.0.0/0"]
}

resource "aws_autoscaling_group" "freeswitch_deb_builder" {
  name                 = "freeswitch-deb-builder"

  launch_template {
    id      = aws_launch_template.freeswitch_deb_builder.id
    version = aws_launch_template.freeswitch_deb_builder.latest_version
  }

  vpc_zone_identifier = module.vpc.private_subnets

  max_size             = 1
  min_size             = 0
  desired_capacity     = 0
  wait_for_capacity_timeout = 0

  termination_policies = ["OldestInstance"]

  tag {
    key                 = "Name"
    value               = "freeswitch-deb-builder"
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
