resource "aws_iam_user" "ci_deploy" {
  name = "ci-deploy"
}

resource "aws_iam_access_key" "ci_deploy" {
  user = aws_iam_user.ci_deploy.name
}

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

resource "aws_iam_policy" "ci_deploy" {
  name = "ci_deploy"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "elasticbeanstalk:UpdateEnvironment",
        "elasticbeanstalk:CreateApplicationVersion",
        "cloudfront:CreateInvalidation"
      ],
      "Resource": "*"
    },
    {
      "Effect": "Allow",
      "Action": [
        "s3:PutObject",
        "s3:GetObject"
      ],
      "Resource": [
        "${aws_s3_bucket.ci_deploy.arn}/*",
        "${aws_s3_bucket.somleng_website.arn}/*"
      ]
    },
    {
      "Effect": "Allow",
      "Action": [
        "s3:PutObject",
        "s3:PutObjectAcl",
        "s3:ListBucket",
        "s3:DeleteObject",
        "s3:Get*"
      ],
      "Resource": [
        "arn:aws:s3:::elasticbeanstalk-*",
        "arn:aws:s3:::elasticbeanstalk-*/*"
      ]
    },
    {
      "Action": [
        "ec2:Describe*"
      ],
      "Effect": "Allow",
      "Resource": "*"
    },
    {
      "Action": [
        "autoscaling:Describe*",
        "autoscaling:SuspendProcesses",
        "autoscaling:ResumeProcesses"
      ],
      "Effect": "Allow",
      "Resource": "*"
    },
    {
      "Action": [
        "elasticloadbalancing:Describe*",
        "elasticloadbalancing:RegisterTargets",
        "elasticloadbalancing:DeregisterTargets"
      ],
      "Effect": "Allow",
      "Resource": "*"
    },
    {
      "Action": [
        "logs:CreateLogGroup",
        "logs:Put*"
      ],
      "Effect": "Allow",
      "Resource": "arn:aws:logs:*:*:log-group:/aws/elasticbeanstalk/*"
    },
    {
      "Action": [
        "logs:Describe*"
      ],
      "Effect": "Allow",
      "Resource": "*"
    },
    {
      "Action": [
        "cloudformation:Get*",
        "cloudformation:Describe*",
        "cloudformation:Update*",
        "cloudformation:Create*",
        "cloudformation:CancelUpdateStack*"
      ],
      "Effect": "Allow",
      "Resource": "arn:aws:cloudformation:*:*:stack/awseb-*/*"
    },
    {
      "Action": [
        "ecs:RegisterTaskDefinition"
      ],
      "Effect": "Allow",
      "Resource": "*"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "ci_deploy" {
  role       = aws_iam_role.ci_deploy.name
  policy_arn = aws_iam_policy.ci_deploy.arn
}