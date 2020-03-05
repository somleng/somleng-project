output "vpc" {
  value = module.vpc
}

output "db_security_group" {
  value = aws_security_group.db
}

output "somleng_db_password_parameter" {
  value = aws_ssm_parameter.somleng_db_master_password
}

output "db" {
  value = module.db
}