output "cdn_certificate" {
  value     = aws_acm_certificate.cdn_certificate
  sensitive = true
}

output "hydrogen_region" {
  value = module.hydrogen_region
}

output "helium_region" {
  value = module.helium_region
}

output "db" {
  value     = module.db
  sensitive = true
}

output "db_staging" {
  value     = module.db_staging
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

output "global_accelerator" {
  value = aws_globalaccelerator_accelerator.somleng
}
