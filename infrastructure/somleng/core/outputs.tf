output "cdn_certificate" {
  value     = aws_acm_certificate.cdn_certificate
  sensitive = true
}

output "vpc_hydrogen" {
  value = module.vpc_hydrogen
}

output "vpc_helium" {
  value = module.vpc_helium
}

output "db_cluster" {
  value     = aws_rds_cluster.db
  sensitive = true
}

output "db_security_group" {
  value = aws_security_group.db
}

output "db_master_password_parameter" {
  value     = aws_ssm_parameter.db_master_password
  sensitive = true
}

output "ci_deploy_key" {
  value     = aws_iam_access_key.ci_deploy
  sensitive = true
}

output "ci_deploy_role" {
  value = aws_iam_role.ci_deploy
}

output "route53_zone_somleng_org" {
  value = aws_route53_zone.somleng_org
}

output "route53_zone_internal_somleng_org" {
  value = aws_route53_zone.somleng_org_internal
}

output "route53_zone_internal_somleng_org_old" {
  value = aws_route53_zone.somleng_org_private_old
}

output "nat_instance_ip" {
  value = aws_eip.nat_instance.public_ip
}

output "global_accelerator" {
  value = aws_globalaccelerator_accelerator.somleng
}
