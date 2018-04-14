resource "aws_iam_group" "s3" {
  name = "s3"
}

resource "aws_iam_group_policy_attachment" "s3" {
  group      = "${aws_iam_group.s3.name}"
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
}

resource "aws_iam_user" "s3" {
  name = "eb-s3"
}

resource "aws_iam_group_membership" "s3" {
  name = "eb-s3"

  users = [
    "${aws_iam_user.s3.name}",
  ]

  group = "${aws_iam_group.s3.name}"
}

resource "aws_iam_access_key" "s3" {
  user = "${aws_iam_user.s3.name}"
}
