resource "aws_iam_user" "ci_deploy" {
  name = "ci-deploy"
}

resource "aws_iam_access_key" "ci_deploy" {
  user = "${aws_iam_user.ci_deploy.name}"
}
