resource "aws_s3_bucket" "ci_deploy" {
  bucket = "deploy.unicef.io"
  acl    = "private"
  region = "${var.aws_region}"
}

resource "aws_s3_bucket" "cdr" {
  bucket = "unicef-io-somleng-cdr"
  acl    = "private"
  region = "${var.aws_region}"
}
