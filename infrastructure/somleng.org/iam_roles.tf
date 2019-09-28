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

resource "aws_iam_role" "secure_headers" {
  name = "secure_headers"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": [
          "lambda.amazonaws.com",
          "edgelambda.amazonaws.com"
        ]
      },
      "Effect": "Allow"
    }
  ]
}
EOF

}

resource "aws_iam_role_policy" "secure_headers" {
  name = "secure_headers"
  role = "${aws_iam_role.secure_headers.id}"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents"
      ],
      "Resource": [
        "arn:aws:logs:*:*:*"
      ]
    }
  ]
}
EOF

}
