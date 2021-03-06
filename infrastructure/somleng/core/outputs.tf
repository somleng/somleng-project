output "acm_certificate" {
  value = aws_acm_certificate.certificate
}

output "somleng_zone" {
  value = aws_route53_zone.somleng_org
}

output "ses_credentials" {
  value = aws_iam_access_key.ses_sender
}

output "vpc" {
  value = module.vpc
}

output "db" {
  value = module.db
  sensitive = true
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

output "ci_deploy_key" {
  value = aws_iam_access_key.ci_deploy
}

output "ci_deploy_role" {
  value = aws_iam_role.ci_deploy
}

output "application_load_balancer" {
  value = aws_lb.somleng_application
}

output "network_load_balancer" {
  value = aws_lb.somleng_network
}

output "https_listener" {
  value = aws_lb_listener.https
}

output "ecs_cluster" {
  value = aws_ecs_cluster.somleng
}

output "nlb_eips" {
  value = aws_eip.nlb.*
}
