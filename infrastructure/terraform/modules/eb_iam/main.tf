resource "aws_iam_role" "eb_service_role" {
  name = "aws-elasticbeanstalk-service-role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "",
      "Effect": "Allow",
      "Principal": {
        "Service": "elasticbeanstalk.amazonaws.com"
      },
      "Action": "sts:AssumeRole",
      "Condition": {
        "StringEquals": {
          "sts:ExternalId": "elasticbeanstalk"
        }
      }
    }
  ]
}
EOF
}

resource "aws_iam_role" "eb_ec2_instance_role" {
  name = "aws-elasticbeanstalk-ec2-role"

  assume_role_policy = <<EOF
{
  "Version": "2008-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_instance_profile" "eb_service" {
  name = "aws-elasticbeanstalk-service-role"
  role = "${aws_iam_role.eb_service_role.name}"
}

resource "aws_iam_instance_profile" "eb_ec2" {
  name = "aws-elasticbeanstalk-ec2-role"
  role = "${aws_iam_role.eb_ec2_instance_role.name}"
}

resource "aws_iam_role_policy_attachment" "eb_service" {
  role       = "${aws_iam_role.eb_service_role.name}"
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSElasticBeanstalkService"
}

resource "aws_iam_role_policy_attachment" "eb_enhanced_health" {
  role       = "${aws_iam_role.eb_service_role.name}"
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSElasticBeanstalkEnhancedHealth"
}

resource "aws_iam_role_policy_attachment" "eb_multicontainer_docker" {
  role       = "${aws_iam_role.eb_ec2_instance_role.name}"
  policy_arn = "arn:aws:iam::aws:policy/AWSElasticBeanstalkMulticontainerDocker"
}

resource "aws_iam_role_policy_attachment" "eb_web_tier" {
  role       = "${aws_iam_role.eb_ec2_instance_role.name}"
  policy_arn = "arn:aws:iam::aws:policy/AWSElasticBeanstalkWebTier"
}

resource "aws_iam_role_policy_attachment" "eb_worker_tier" {
  role       = "${aws_iam_role.eb_ec2_instance_role.name}"
  policy_arn = "arn:aws:iam::aws:policy/AWSElasticBeanstalkWorkerTier"
}

resource "aws_iam_role_policy_attachment" "sqs" {
  role       = "${aws_iam_role.eb_ec2_instance_role.name}"
  policy_arn = "arn:aws:iam::aws:policy/AmazonSQSFullAccess"
}

resource "aws_iam_role_policy_attachment" "ssm" {
  role       = "${aws_iam_role.eb_ec2_instance_role.name}"
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2RoleforSSM"
}

resource "aws_iam_role_policy_attachment" "polly" {
  role       = "${aws_iam_role.eb_ec2_instance_role.name}"
  policy_arn = "arn:aws:iam::aws:policy/AmazonPollyFullAccess"
}
