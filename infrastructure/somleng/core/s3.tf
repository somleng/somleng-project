data "aws_elb_service_account" "main" {}

resource "aws_s3_bucket" "naked_redirect" {
  bucket = "somleng.org"
  acl    = "private"

  website {
    redirect_all_requests_to = "https://www.somleng.org"
  }
}

resource "aws_s3_bucket" "somleng_website" {
  bucket = "www.somleng.org"
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
        "arn:aws:s3:::www.somleng.org/*"
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
  bucket = "logs.somleng.org"
  acl    = "private"
}

resource "aws_s3_bucket_policy" "logs" {
  bucket = aws_s3_bucket.logs.id

  policy = <<POLICY
{
  "Version": "2012-10-17",
  "Id": "Policy1429136655940",
  "Statement": [
    {
      "Sid": "Stmt1429136633762",
      "Effect": "Allow",
      "Principal": {
        "AWS": "${data.aws_elb_service_account.main.arn}"
      },
      "Action": "s3:PutObject",
      "Resource": "arn:aws:s3:::${aws_s3_bucket.logs.id}/*"
    },
    {
      "Sid": "AWSLogDeliveryWrite",
      "Effect": "Allow",
      "Principal": {
        "Service": "delivery.logs.amazonaws.com"
      },
      "Action": "s3:PutObject",
      "Resource": "arn:aws:s3:::${aws_s3_bucket.logs.id}/*",
      "Condition": {"StringEquals": {"s3:x-amz-acl": "bucket-owner-full-control"}}
    },
    {
      "Sid": "AWSLogDeliveryAclCheck",
      "Effect": "Allow",
      "Principal": {
        "Service": "delivery.logs.amazonaws.com"
      },
      "Action": "s3:GetBucketAcl",
      "Resource": "arn:aws:s3:::${aws_s3_bucket.logs.id}"
    }
  ]
}
POLICY
}