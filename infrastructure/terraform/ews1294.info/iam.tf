module "terraform_iam" {
  source      = "../modules/terraform_iam"
}

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

variable "aws_rds_master_passwords" {
  type = "map"

  default = {
    scfm = ""
  }
}
variable "aws_rails_master_passwords" {
  type = "map"

  default = {
    scfm = ""
  }
}

resource "aws_kms_key" "master" {
  description             = "Master Key"
  enable_key_rotation     = true

  tags {
    Name = "terraform-master-key"
  }
}

resource "aws_kms_alias" "master" {
  name          = "alias/pin-master"
  target_key_id = "${aws_kms_key.master.key_id}"
}

output "aws_kms_key_master" {
  value = "${aws_kms_key.master.id}"
}

# data "aws_kms_secret" "scfm_db" {
#   secret {
#     name    = "scfm_db_master_password"
#     payload = "${var.aws_rds_master_passwords[scfm]}"
#   }
# }
#
# data "aws_kms_secret" "scfm_rails_master_key" {
#   secret {
#     name    = "scfm_rails_master_key"
#     payload = "${var.aws_rails_master_passwords[scfm]}"
#   }
# }
