data "aws_iam_role" "eb_service_role" {
  name = "aws-elasticbeanstalk-service-role"
}

data "aws_iam_role" "eb_ec2_instance_role" {
  name = "aws-elasticbeanstalk-ec2-role"
}

resource "aws_iam_role_policy_attachment" "eb_enhanced_health" {
  role       = "${data.aws_iam_role.eb_service_role.name}"
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSElasticBeanstalkEnhancedHealth"
}

resource "aws_iam_role_policy_attachment" "eb_service" {
  role       = "${data.aws_iam_role.eb_service_role.name}"
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSElasticBeanstalkService"
}

resource "aws_iam_role_policy_attachment" "sqs" {
  role       = "${data.aws_iam_role.eb_ec2_instance_role.name}"
  policy_arn = "arn:aws:iam::aws:policy/AmazonSQSFullAccess"
}

resource "aws_iam_role_policy_attachment" "ssm" {
  role       = "${data.aws_iam_role.eb_ec2_instance_role.name}"
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2RoleforSSM"
}
