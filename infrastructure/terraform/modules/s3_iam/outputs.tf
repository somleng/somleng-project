output "s3_access_key_id" {
  value = "${aws_iam_access_key.s3.id}"
}

output "s3_secret_access_key" {
  value = "${aws_iam_access_key.s3.secret}"
}
