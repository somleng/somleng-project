output "vpc" {
  value = module.vpc
}

output "twilreapi_db_security_group" {
  value = aws_security_group.twilreapi_db
}

output "twilreapi_db" {
  value = module.twilreapi_db
}
