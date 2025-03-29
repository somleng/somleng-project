resource "aws_s3_bucket" "naked_redirect" {
  bucket = "somleng.org"
}

resource "aws_s3_bucket_acl" "naked_redirect" {
  bucket = aws_s3_bucket.naked_redirect.id
  acl    = "private"
}

resource "aws_s3_bucket_website_configuration" "naked_redirect" {
  bucket = aws_s3_bucket.naked_redirect.id
  redirect_all_requests_to {
    host_name = "www.somleng.org"
    protocol  = "https"
  }
}

resource "aws_s3_bucket" "somleng_website" {
  bucket = "www.somleng.org"

}

resource "aws_s3_bucket_acl" "somleng_website" {
  bucket = aws_s3_bucket.somleng_website.id
  acl    = "public-read"
}

resource "aws_s3_bucket_website_configuration" "somleng_website" {
  bucket = aws_s3_bucket.somleng_website.id

  index_document {
    suffix = "index.html"
  }
}

resource "aws_s3_bucket_policy" "somleng_website" {
  bucket = aws_s3_bucket.somleng_website.id

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
        "${aws_s3_bucket.somleng_website.arn}/*"
      ]
    }
  ]
}
POLICY
}

resource "aws_s3_bucket" "backups" {
  bucket = "backups.somleng.org"
}

resource "aws_s3_bucket_acl" "backups" {
  bucket = aws_s3_bucket.backups.id
  acl    = "private"
}

resource "aws_s3_bucket" "ci_artifacts" {
  bucket = "ci-artifacts.somleng.org"
}

resource "aws_s3_bucket_lifecycle_configuration" "ci_artifacts" {
  bucket = aws_s3_bucket.ci_artifacts.id

  rule {
    id     = "rule-1"
    status = "Enabled"

    expiration {
      days = 1
    }
  }
}
