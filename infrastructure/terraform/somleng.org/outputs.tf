output "aws_kms_key_master" {
  value = "${aws_kms_key.master.id}"
}

output "travis_aws_access_key_id" {
  value = "${module.ci_iam.travis_access_key_id}"
}

output "travis_aws_secret_access_key" {
  value = "${module.ci_iam.travis_access_key_secret}"
}

output "ci-deploy-bucket" {
  value = "${aws_s3_bucket.ci_deploy.id}"
}
