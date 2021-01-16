data "aws_ami" "this" {
  most_recent = true
  owners = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-2.0.????????.?-x86_64-gp2"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

data "aws_s3_bucket" "backups" {
  bucket = "backups.somleng.org"
}

resource "aws_security_group" "this" {
  name   = "backup-database"
  vpc_id = data.terraform_remote_state.old_infrastructure.outputs.vpc.vpc_id
}

resource "aws_security_group_rule" "egress" {
  type              = "egress"
  to_port           = 0
  protocol          = "-1"
  from_port         = 0
  security_group_id = aws_security_group.this.id
  cidr_blocks = ["0.0.0.0/0"]
}

resource "aws_instance" "this" {
  ami           = data.aws_ami.this.id
  instance_type = "t3.small"
  security_groups = [
    aws_security_group.this.id,
  ]
  subnet_id = element(data.terraform_remote_state.old_infrastructure.outputs.vpc.private_subnets, 0)
  iam_instance_profile = aws_iam_instance_profile.this.id
  user_data = data.template_file.user_data.rendered

  root_block_device {
    volume_size = 20
    volume_type = "gp2"
  }

  tags = {
    Name = "backup-database"
  }
}

resource "aws_iam_role" "this" {
name  = "backup-database"

assume_role_policy = <<EOF
{
  "Version": "2008-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_instance_profile" "this" {
  name  = aws_iam_role.this.name
  role  = aws_iam_role.this.name
}

resource "aws_iam_policy" "this" {
  name = "backup-database"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "s3:ListBucket"
      ],
      "Resource": [
        "${data.aws_s3_bucket.backups.arn}"
      ]
    },
    {
      "Effect": "Allow",
      "Action": [
        "s3:PutObject",
        "s3:GetObject",
        "s3:DeleteObject"
      ],
      "Resource": [
        "${data.aws_s3_bucket.backups.arn}/*"
      ]
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "this" {
  role       = aws_iam_role.this.name
  policy_arn = aws_iam_policy.this.arn
}

resource "aws_iam_role_policy_attachment" "ssm" {
  role       = aws_iam_role.this.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2RoleforSSM"
}

data "template_file" "user_data" {
  template = file("${path.module}/user-data.sh")

  vars = {
    old_db_host = "old_db_host"
    old_db_username = "old_db_username"
    old_db_password = "old_db_password"
    old_db_name = "old_db_name"
    application_name = var.application_name
  }
}
