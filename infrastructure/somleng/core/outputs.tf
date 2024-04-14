output "acm_certificate" {
  value     = aws_acm_certificate.certificate
  sensitive = true
}

output "internal_certificate" {
  value     = aws_acm_certificate.internal_certificate
  sensitive = true
}

output "cdn_certificate" {
  value     = aws_acm_certificate.cdn_certificate
  sensitive = true
}

output "vpc" {
  value = module.vpc
}

output "db_cluster" {
  value     = aws_rds_cluster.db
  sensitive = true
}

output "db_security_group" {
  value = aws_security_group.db
}

output "logs_bucket" {
  value = aws_s3_bucket.logs
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

output "application_load_balancer" {
  value = aws_lb.somleng_application
}

output "internal_application_load_balancer" {
  value = aws_lb.somleng_internal_application
}

output "network_load_balancer" {
  value = aws_lb.somleng_network
}

output "https_listener" {
  value = aws_lb_listener.https
}

output "internal_https_listener" {
  value = aws_lb_listener.internal_https
}

output "nlb_eips" {
  value = aws_eip.nlb.*
}

output "route53_zone_somleng_org" {
  value = aws_route53_zone.somleng_org
}

output "route53_zone_internal_somleng_org" {
  value = aws_route53_zone.somleng_org_private
}

output "nat_instance_ip" {
  value = aws_eip.nat_instance.public_ip
}

output "global_accelerator" {
  value = aws_globalaccelerator_accelerator.somleng
}
