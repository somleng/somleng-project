# https://aws.amazon.com/ec2/instance-types/t4/
data "aws_ssm_parameter" "arm64_ami" {
  name = "/aws/service/ami-amazon-linux-latest/al2022-ami-kernel-default-arm64"
}

data "aws_ssm_parameter" "db_master_password" {
  name = "${var.db_master_password_parameter_identifier}.db_master_password"
}

data "aws_s3_bucket" "backups" {
  bucket = "backups.somleng.org"
}

data "aws_rds_cluster" "db_cluster" {
  cluster_identifier = var.cluster_identifier
}

data "aws_security_group" "db" {
  filter {
    name   = "tag:Name"
    values = ["aurora-${var.cluster_identifier}"]
  }
}

resource "aws_security_group" "this" {
  name   = "bootstrap-database"
  vpc_id = data.terraform_remote_state.core_infrastructure.outputs.vpc.vpc_id
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
  ami           = data.aws_ssm_parameter.arm64_ami.value
  instance_type = "t4g.micro"
  security_groups = [aws_security_group.this.id, data.aws_security_group.db.id]
  subnet_id = element(data.terraform_remote_state.core_infrastructure.outputs.vpc.private_subnets, 0)
  iam_instance_profile = aws_iam_instance_profile.this.id
  user_data = data.template_file.user_data.rendered

  tags = {
    Name = "bootstrap-database"
  }
}

resource "aws_iam_role" "this" {
name  = "bootstrap-database"

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
  name = "bootstrap-database"

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
        "s3:GetObject"
      ],
      "Resource": [
        "${data.aws_s3_bucket.backups.arn}/*"
      ]
    },
    {
      "Effect": "Allow",
      "Action": [
        "ssm:GetParameter"
      ],
      "Resource": [
        "${data.aws_ssm_parameter.db_master_password.arn}"
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
    db_host = data.aws_rds_cluster.db_cluster.endpoint
    db_username = data.aws_rds_cluster.db_cluster.master_username
    db_master_password_parameter_name = data.aws_ssm_parameter.db_master_password.name
    db_name = var.db_name
    create_db = var.create_db
    restore_db = var.restore_db
    restore_db_from_backup_name = var.restore_db_from_backup_name
  }
}
