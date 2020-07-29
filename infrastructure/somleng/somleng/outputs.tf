output "vpc" {
  value = module.vpc
}

output "scfm_db_security_group" {
  value = aws_security_group.scfm_db
}

output "scfm_db" {
  value = module.scfm_db
}

output "twilreapi_db_security_group" {
  value = aws_security_group.twilreapi_db
}

output "twilreapi_db" {
  value = module.twilreapi_db
}