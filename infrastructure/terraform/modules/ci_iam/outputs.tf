output "travis_access_key_id" {
  value = "${aws_iam_access_key.travis.id}"
}

output "travis_access_key_secret" {
  value = "${aws_iam_access_key.travis.secret}"
}
