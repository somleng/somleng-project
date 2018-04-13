output "terraform_aws_access_key_id" {
  value = "${module.terraform_iam.terraform_aws_access_key_id}"
}

output "terraform_aws_secret_access_key" {
  value = "${module.terraform_iam.terraform_aws_secret_access_key}"
}

output "aws_kms_key_master" {
  value = "${aws_kms_key.master.id}"
}
