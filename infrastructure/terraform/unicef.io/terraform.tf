variable "aws_region" {
  default = "ap-southeast-1"
}

provider "aws" {
  shared_credentials_file = "~/.aws/credentials"
  profile                 = "unicef-terraform"
  region                  = "${var.aws_region}"
}

resource "aws_s3_bucket" "terraform_bucket" {
  bucket = "terraform.unicef.io"

  versioning {
    enabled = true
  }

  lifecycle {
    prevent_destroy = true
  }

  tags {
    Name = "S3 Remote Terraform State Store"
  }
}

terraform {
  backend "s3" {
    bucket  = "terraform.unicef.io"
    key     = "terraform.tfstate"
    encrypt = true
  }
}

resource "aws_iam_group" "terraform" {
  name = "terraform"
}

resource "aws_iam_group_policy_attachment" "terraform_iam" {
  group      = "${aws_iam_group.terraform.name}"
  policy_arn = "arn:aws:iam::aws:policy/IAMFullAccess"
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

resource "aws_iam_user" "terraform" {
  name = "terraform"
}

resource "aws_iam_group_membership" "s3" {
  name = "terraform"

  users = [
    "${aws_iam_user.terraform.name}",
  ]

  group = "${aws_iam_group.terraform.name}"
}

resource "aws_iam_access_key" "terraform" {
  user = "${aws_iam_user.terraform.name}"
}

output "terraform_access_key_id" {
  value = "${aws_iam_access_key.terraform.id}"
}

output "terraform_access_key_secret" {
  value = "${aws_iam_access_key.terraform.secret}"
}
