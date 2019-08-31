resource "aws_iam_role" "ci_deploy" {
  name = "ci-deploy"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Effect": "Allow",
      "Principal": {
        "AWS": [
          "${aws_iam_user.ci_deploy.arn}"
        ]
      }
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "ci_deploy" {
  role       = "${aws_iam_role.ci_deploy.name}"
  policy_arn = "${aws_iam_policy.ci_deploy.arn}"
}
