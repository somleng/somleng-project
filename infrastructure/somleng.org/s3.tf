locals {
  deploy_bucket  = "deploy.${local.route53_domain_name}"
  cdr_bucket     = "cdr.${local.route53_domain_name}"
  audio_bucket   = "audio.${local.route53_domain_name}"
  uploads_bucket = "uploads.${local.route53_domain_name}"
  backups_bucket = "backups.${local.route53_domain_name}"
  logs_bucket    = "logs.${local.route53_domain_name}"
  docs_bucket = "docs.${local.route53_domain_name}"
  elb_logging_account_id = "114774131450" # "For ap-southeast-1. See https://amzn.to/2uXbInO"
}

resource "aws_s3_bucket" "ci_deploy" {
  bucket = "${local.deploy_bucket}"
  acl    = "private"
  region = "${var.aws_region}"
}

resource "aws_s3_bucket" "backups" {
  bucket = "${local.backups_bucket}"
  acl    = "private"
  region = "${var.aws_region}"
}

resource "aws_s3_bucket" "cdr" {
  bucket = "${local.cdr_bucket}"
  acl    = "private"
  region = "${var.aws_region}"
}

resource "aws_s3_bucket" "uploads" {
  bucket = "${local.uploads_bucket}"
  acl    = "private"
  region = "${var.aws_region}"

  cors_rule {
    allowed_headers = ["*"]
    allowed_methods = ["GET", "POST", "PUT"]
    allowed_origins = ["https://*.${local.route53_domain_name}"]
    max_age_seconds = 3000
  }
}

resource "aws_s3_bucket" "audio" {
  bucket = "${local.audio_bucket}"
  acl    = "public-read"
  region = "${var.aws_region}"

  policy = <<POLICY
{
  "Version":"2012-10-17",
  "Statement":[
    {
      "Sid":"AddPerm",
      "Effect":"Allow",
      "Principal": "*",
      "Action":["s3:GetObject"],
      "Resource":["arn:aws:s3:::${local.audio_bucket}/*"]
    }
  ]
}
  POLICY
}

resource "aws_s3_bucket" "docs" {
  bucket = "${local.docs_bucket}"
  acl    = "public-read"

  policy = <<POLICY
{
  "Version":"2012-10-17",
  "Statement": [
    {
      "Effect":"Allow",
      "Principal": "*",
      "Action": [
        "s3:GetObject"
      ],
      "Resource":[
        "arn:aws:s3:::${local.docs_bucket}/*"
      ]
    }
  ]
}
POLICY


  website {
    index_document = "index.html"
  }
}

resource "aws_s3_bucket" "logs" {
  bucket = "${local.logs_bucket}"
  acl    = "private"
}

resource "aws_s3_bucket_policy" "logs" {
  bucket = "${aws_s3_bucket.logs.id}"

  policy = <<POLICY
{
  "Version": "2012-10-17",
  "Id": "Policy1429136655940",
  "Statement": [
    {
      "Sid": "Stmt1429136633762",
      "Effect": "Allow",
      "Principal": {
        "AWS": "arn:aws:iam::${local.elb_logging_account_id}:root"
      },
      "Action": "s3:PutObject",
      "Resource": "arn:aws:s3:::${local.logs_bucket}/*"
    },
    {
      "Sid": "AWSLogDeliveryWrite",
      "Effect": "Allow",
      "Principal": {
        "Service": "delivery.logs.amazonaws.com"
      },
      "Action": "s3:PutObject",
      "Resource": "arn:aws:s3:::${local.logs_bucket}/*",
      "Condition": {"StringEquals": {"s3:x-amz-acl": "bucket-owner-full-control"}}
    },
    {
      "Sid": "AWSLogDeliveryAclCheck",
      "Effect": "Allow",
      "Principal": {
        "Service": "delivery.logs.amazonaws.com"
      },
      "Action": "s3:GetBucketAcl",
      "Resource": "arn:aws:s3:::${local.logs_bucket}"
    }
  ]
}
POLICY

}
