output "this" {
  value = aws_rds_cluster.this
}

output "security_group" {
  value = aws_security_group.this
}

output "master_password_parameter" {
  value     = aws_ssm_parameter.db_master_password
  sensitive = true
}
