resource "aws_iam_group" "terraform" {
  name = "terraform"
}

resource "aws_iam_group_policy_attachment" "terraform_iam" {
  group      = "${aws_iam_group.terraform.name}"
  policy_arn = "arn:aws:iam::aws:policy/IAMFullAccess"
}

resource "aws_iam_group_policy_attachment" "terraform_vpc" {
  group      = "${aws_iam_group.terraform.name}"
  policy_arn = "arn:aws:iam::aws:policy/AmazonVPCFullAccess"
}

resource "aws_iam_group_policy_attachment" "terraform_admin" {
  group      = "${aws_iam_group.terraform.name}"
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
}

resource "aws_iam_group_policy_attachment" "terraform_route53_domains" {
  group      = "${aws_iam_group.terraform.name}"
  policy_arn = "arn:aws:iam::aws:policy/AmazonRoute53DomainsFullAccess"
}

resource "aws_iam_group_policy_attachment" "terraform_cloudfront" {
  group      = "${aws_iam_group.terraform.name}"
  policy_arn = "arn:aws:iam::aws:policy/CloudFrontFullAccess"
}

resource "aws_iam_group_policy_attachment" "terraform_elastic_beanstalk" {
  group      = "${aws_iam_group.terraform.name}"
  policy_arn = "arn:aws:iam::aws:policy/AWSElasticBeanstalkFullAccess"
}

resource "aws_iam_group_policy_attachment" "terraform_route_53" {
  group      = "${aws_iam_group.terraform.name}"
  policy_arn = "arn:aws:iam::aws:policy/AmazonRoute53FullAccess"
}

resource "aws_iam_group_policy_attachment" "terraform_kms" {
  group      = "${aws_iam_group.terraform.name}"
  policy_arn = "arn:aws:iam::aws:policy/AWSKeyManagementServicePowerUser"
}

resource "aws_iam_group_policy_attachment" "terraform_s3" {
  group      = "${aws_iam_group.terraform.name}"
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
}

resource "aws_iam_user" "terraform" {
  name = "terraform"
}

resource "aws_iam_group_membership" "terraform" {
  name = "terraform"

  users = [
    "${aws_iam_user.terraform.name}",
  ]

  group = "${aws_iam_group.terraform.name}"
}

resource "aws_iam_access_key" "terraform" {
  user = "${aws_iam_user.terraform.name}"
}
