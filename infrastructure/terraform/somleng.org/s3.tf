resource "aws_s3_bucket" "ci_deploy" {
  bucket = "deploy.somleng.org"
  acl    = "private"
  region = "${var.aws_region}"
}

resource "aws_s3_bucket" "cdr" {
  bucket = "cdr.somleng.org"
  acl    = "private"
  region = "${var.aws_region}"
}
