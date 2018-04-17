resource "aws_s3_bucket" "ci_deploy" {
  bucket = "deploy.ews1294.info"
  acl    = "private"
  region = "${var.aws_region}"
}

resource "aws_s3_bucket" "uploads" {
  bucket = "somlengcdr"
  acl    = "private"
  region = "${var.aws_region}"
}
