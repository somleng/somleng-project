output "this" {
  value = aws_rds_cluster.this
}

output "master_password_parameter" {
  value     = aws_ssm_parameter.db_master_password
  sensitive = true
}
