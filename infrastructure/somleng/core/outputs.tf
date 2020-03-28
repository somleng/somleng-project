output "acm_certificate" {
  value = aws_acm_certificate.certificate
}

output "somleng_zone" {
  value = aws_route53_zone.somleng_org
}

output "somleng_internal_zone" {
  value = aws_route53_zone.internal
}

output "ses_credentials" {
  value = aws_iam_access_key.ses_sender
}

output "vpc" {
  value = module.vpc
}

output "db" {
  value = module.db
}

output "db_security_group" {
  value = aws_security_group.db
}

output "codedeploy_role" {
  value = aws_iam_role.codedeploy
}

output "logs_bucket" {
  value = aws_s3_bucket.logs
}

output "db_master_password_parameter" {
  value = aws_ssm_parameter.db_master_password
}