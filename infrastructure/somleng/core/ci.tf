locals {
  open_ews_arn = "arn:aws:s3:::www.open-ews.org"
}

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
        "cloudfront:CreateInvalidation"
      ],
      "Resource": "*"
    },
    {
      "Effect": "Allow",
      "Action": [
        "s3:ListBucket"
      ],
      "Resource": [
        "${local.open_ews_arn}",
        "${aws_s3_bucket.somleng_website.arn}",
        "${aws_s3_bucket.ci_artifacts.arn}"
      ]
    },
    {
      "Effect": "Allow",
      "Action": [
        "s3:PutObject",
        "s3:PutObjectAcl",
        "s3:GetObject",
        "s3:GetObjectAcl",
        "s3:DeleteObject"
      ],
      "Resource": [
        "${local.open_ews_arn}/*",
        "${aws_s3_bucket.somleng_website.arn}/*",
        "${aws_s3_bucket.ci_artifacts.arn}/*"
      ]
    },
    {
      "Effect": "Allow",
      "Action": [
        "lambda:UpdateFunctionCode"
      ],
      "Resource": "*"
    },
    {
      "Action": [
        "ecs:RegisterTaskDefinition*",
        "ecs:Describe*",
        "ecs:UpdateService",
        "ecs:RunTask"
      ],
      "Effect": "Allow",
      "Resource": "*"
    },
    {
      "Action": [
        "iam:PassRole"
      ],
      "Effect": "Allow",
      "Resource": [
        "arn:aws:iam::***:role/*ecs*"
      ]
    },
    {
      "Action": [
        "ecs:DescribeServices"
      ],
      "Effect": "Allow",
      "Resource": [
        "arn:aws:ecs:::service/*"
      ]
    },
    {
      "Effect": "Allow",
      "Action": [
        "polly:DescribeVoices"
      ],
      "Resource": "*"
    },
    {
      "Effect": "Allow",
      "Action": [
        "codebuild:StartBuild",
        "codebuild:BatchGetBuilds"
      ],
      "Resource": "*"
    },
    {
      "Effect": "Allow",
      "Action": ["logs:GetLogEvents"],
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

resource "aws_iam_role_policy_attachment" "ci_ecr" {
  role       = aws_iam_role.ci_deploy.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryPowerUser"
}

resource "aws_iam_role_policy_attachment" "ci_ecr_public" {
  role       = aws_iam_role.ci_deploy.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonElasticContainerRegistryPublicPowerUser"
}
