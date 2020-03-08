output "aws_kms_key_master" {
  value = "${aws_kms_key.master.id}"
}

output "ci_deploy_bucket" {
  value = "${aws_s3_bucket.ci_deploy.id}"
}

output "ci_deploy_user_access_key_id" {
  value = "${aws_iam_access_key.ci_deploy.id}"
}

output "ci_deploy_user_secret_access_key" {
  value = "${aws_iam_access_key.ci_deploy.secret}"
}

output "ci_deploy_role_arn" {
  value = "${aws_iam_role.ci_deploy.arn}"
}
