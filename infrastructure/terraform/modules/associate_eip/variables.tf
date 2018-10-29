variable "lambda_iam_role_name" {
  default = "lambda-associate-eip"
}

variable "lambda_iam_policy_name" {
  default = "lambda-associate-eip-policy"
}

variable "eip_allocation_id" {}

variable "autoscaling_group" {}

variable "cloudwatch_event_rule_name" {
  default = "associate-eip"
}

variable "cloudwatch_event_rule_description" {
  default = "Associate Elastic IP"
}
