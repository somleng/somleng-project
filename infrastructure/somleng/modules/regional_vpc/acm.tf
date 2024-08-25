module "public_ssl_certificate" {
  source = "../ssl_certificate"

  count                     = var.create_public_load_balancer ? 1 : 0
  domain_name               = var.ssl_certificate_domain_name
  subject_alternative_names = var.public_ssl_certificate_subject_alternative_names
  route53_zone              = var.route53_zone
}

module "internal_ssl_certificate" {
  source = "../ssl_certificate"

  count                     = var.create_internal_load_balancer ? 1 : 0
  domain_name               = var.ssl_certificate_domain_name
  subject_alternative_names = var.internal_ssl_certificate_subject_alternative_names
  route53_zone              = var.route53_zone
}
