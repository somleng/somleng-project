resource "aws_vpc" "somleng_com" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true

  tags = {
    Name = "somleng.com proxy"
  }
}

resource "aws_subnet" "somleng_com" {
  vpc_id                  = aws_vpc.somleng_com.id
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = true

  tags = {
    Name = "somleng.com"
  }
}

resource "aws_internet_gateway" "somleng_com" {
  vpc_id = aws_vpc.somleng_com.id

  tags = {
    Name = "somleng.com"
  }
}

resource "aws_route" "somleng_com" {
  route_table_id            = aws_vpc.somleng_com.default_route_table_id
  destination_cidr_block    = "0.0.0.0/0"
  gateway_id = aws_internet_gateway.somleng_com.id
}

resource "aws_security_group" "somleng_com" {
  name        = "somleng_com"
  description = "somleng.com proxy"
  vpc_id      = aws_vpc.somleng_com.id
}

resource "aws_security_group_rule" "ingress_http" {
  type              = "ingress"
  to_port           = 80
  protocol          = "TCP"
  from_port         = 80
  security_group_id = aws_security_group.somleng_com.id
  cidr_blocks = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "ingress_https" {
  type              = "ingress"
  to_port           = 443
  protocol          = "TCP"
  from_port         = 443
  security_group_id = aws_security_group.somleng_com.id
  cidr_blocks = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "egress" {
  type              = "egress"
  to_port           = 0
  protocol          = "-1"
  from_port         = 0
  security_group_id = aws_security_group.somleng_com.id
  cidr_blocks = ["0.0.0.0/0"]
}

resource "aws_iam_role" "somleng_com" {
name  = "somleng-com-proxy"

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

resource "aws_iam_instance_profile" "somleng_com" {
  name  = aws_iam_role.somleng_com.name
  role  = aws_iam_role.somleng_com.name
}

resource "aws_iam_role_policy_attachment" "ssm" {
  role       = aws_iam_role.somleng_com.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2RoleforSSM"
}

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

resource "aws_instance" "proxy" {
  ami           = data.aws_ami.this.id
  instance_type = "t3.micro"
  associate_public_ip_address = true
  subnet_id = aws_subnet.somleng_com.id
  iam_instance_profile = aws_iam_instance_profile.somleng_com.id

  user_data = data.template_file.user_data.rendered

  vpc_security_group_ids = [
    aws_security_group.somleng_com.id,
  ]

  tags = {
    Name = "somleng.com proxy"
  }
}

data "template_file" "user_data" {
  template = file("${path.module}/templates/user_data.sh")

  vars = {
    nginx_conf = data.template_file.nginx_conf.rendered
  }
}

data "template_file" "nginx_conf" {
  template = file("${path.module}/templates/nginx.conf")

  vars = {
    api_host = "api.somleng.com"
    dashboard_host = "dashboard2.somleng.com"
  }
}

resource "aws_route53_record" "dashboard2" {
  zone_id = aws_route53_zone.somleng_com.zone_id
  name    = "dashboard2.somleng.com"
  type    = "A"
  ttl     = "300"
  records = [aws_instance.proxy.public_ip]
}
