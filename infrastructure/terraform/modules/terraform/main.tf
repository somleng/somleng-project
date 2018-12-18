locals {
  bastion_host_name = "bastion-host"
}

module "terraform_ec2_iam" {
  source = "../ec2_role"

  role_name = "terraform"
}

resource "aws_iam_role_policy_attachment" "terraform_iam" {
  role       = "${module.terraform_ec2_iam.role_name}"
  policy_arn = "arn:aws:iam::aws:policy/IAMFullAccess"
}

resource "aws_iam_role_policy_attachment" "terraform_vpc" {
  role       = "${module.terraform_ec2_iam.role_name}"
  policy_arn = "arn:aws:iam::aws:policy/AmazonVPCFullAccess"
}

resource "aws_iam_role_policy_attachment" "terraform_route53_domains" {
  role       = "${module.terraform_ec2_iam.role_name}"
  policy_arn = "arn:aws:iam::aws:policy/AmazonRoute53DomainsFullAccess"
}

resource "aws_iam_role_policy_attachment" "terraform_cloudfront" {
  role       = "${module.terraform_ec2_iam.role_name}"
  policy_arn = "arn:aws:iam::aws:policy/CloudFrontFullAccess"
}

resource "aws_iam_role_policy_attachment" "terraform_elastic_beanstalk" {
  role       = "${module.terraform_ec2_iam.role_name}"
  policy_arn = "arn:aws:iam::aws:policy/AWSElasticBeanstalkFullAccess"
}

resource "aws_iam_role_policy_attachment" "terraform_route_53" {
  role       = "${module.terraform_ec2_iam.role_name}"
  policy_arn = "arn:aws:iam::aws:policy/AmazonRoute53FullAccess"
}

resource "aws_iam_role_policy_attachment" "terraform_kms" {
  role       = "${module.terraform_ec2_iam.role_name}"
  policy_arn = "arn:aws:iam::aws:policy/AWSKeyManagementServicePowerUser"
}

resource "aws_iam_role_policy_attachment" "terraform_s3" {
  role       = "${module.terraform_ec2_iam.role_name}"
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
}

resource "aws_iam_role_policy_attachment" "terraform_acm" {
  role       = "${module.terraform_ec2_iam.role_name}"
  policy_arn = "arn:aws:iam::aws:policy/AWSCertificateManagerFullAccess"
}

resource "aws_iam_role_policy_attachment" "terraform_ssm" {
  role       = "${module.terraform_ec2_iam.role_name}"
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2RoleforSSM"
}

data "aws_ami" "amazon_linux2" {
  most_recent = true

  filter {
    name   = "owner-alias"
    values = ["amazon"]
  }

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm*gp2"]
  }
}

resource "aws_instance" "bastion_host" {
  ami                         = "${data.aws_ami.amazon_linux2.id}"
  instance_type               = "t3.nano"
  iam_instance_profile        = "${module.terraform_ec2_iam.instance_profile_name}"
  associate_public_ip_address = false
  subnet_id                   = "${var.bastion_host_subnet_id}"

  tags = {
    Name = "${local.bastion_host_name}"
  }

  provisioner "local-exec" {
    command = "${path.module}/bin/terraform-remote install ${local.bastion_host_name}"
  }
}
