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
        "arn:aws:s3:::${aws_s3_bucket.ci_deploy.id}/*",
        "arn:aws:s3:::${aws_s3_bucket.website.id}/*"
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
    }
  ]
}
EOF
}
