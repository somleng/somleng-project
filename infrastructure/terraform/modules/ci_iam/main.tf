resource "aws_iam_group" "ci" {
  name = "ci"
}

resource "aws_iam_group_policy_attachment" "ci_s3" {
  group      = "${aws_iam_group.ci.name}"
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
}

resource "aws_iam_group_policy_attachment" "ci_eb" {
  group      = "${aws_iam_group.ci.name}"
  policy_arn = "arn:aws:iam::aws:policy/AWSElasticBeanstalkFullAccess"
}

resource "aws_iam_user" "travis" {
  name = "travis"
}

resource "aws_iam_group_membership" "travis" {
  name = "ci-travis"

  users = [
    "${aws_iam_user.travis.name}",
  ]

  group = "${aws_iam_group.ci.name}"
}

resource "aws_iam_access_key" "travis" {
  user = "${aws_iam_user.travis.name}"
}
