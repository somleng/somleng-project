locals {
  deploy_bucket = "deploy.${local.route53_domain_name}"
  cdr_bucket = "cdr.${local.route53_domain_name}"
  audio_bucket = "audio.${local.route53_domain_name}"
  uploads_bucket = "uploads.${local.route53_domain_name}"
}

resource "aws_s3_bucket" "ci_deploy" {
  bucket = "${local.deploy_bucket}"
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
