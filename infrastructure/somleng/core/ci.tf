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
        "${aws_s3_bucket.ci_deploy.arn}",
        "${aws_s3_bucket.somleng_website.arn}"
      ]
    },
    {
      "Effect": "Allow",
      "Action": [
        "s3:PutObject",
        "s3:PutObjectAcl",
        "s3:GetObject",
        "s3:DeleteObject"
      ],
      "Resource": [
        "${aws_s3_bucket.ci_deploy.arn}/*",
        "${aws_s3_bucket.somleng_website.arn}/*"
      ]
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
        "ecs:DescribeServices",
        "codedeploy:GetDeploymentGroup",
        "codedeploy:CreateDeployment",
        "codedeploy:GetDeployment",
        "codedeploy:GetDeploymentConfig",
        "codedeploy:RegisterApplicationRevision"
      ],
      "Effect": "Allow",
      "Resource": [
        "arn:aws:ecs:::service/*",
        "arn:aws:codedeploy:*:***:deploymentgroup:*",
        "arn:aws:codedeploy:*:***:deploymentconfig:*",
        "arn:aws:codedeploy:*:***:application:*"
      ]
    },
    {
      "Effect": "Allow",
      "Action": [
        "polly:DescribeVoices"
      ],
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
