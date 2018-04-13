output "terraform_aws_access_key_id" {
  value = "${aws_iam_access_key.terraform.id}"
}

output "terraform_aws_secret_access_key" {
  value = "${aws_iam_access_key.terraform.secret}"
}
