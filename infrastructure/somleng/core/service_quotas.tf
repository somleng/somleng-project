resource "aws_servicequotas_service_quota" "eip_limit" {
  quota_code   = "L-0263D0A3"
  service_code = "ec2"
  value        = 100
}

resource "aws_servicequotas_service_quota" "security_group_rules_limit" {
  quota_code   = "L-0EA8095F"
  service_code = "vpc"
  value        = 100
}
