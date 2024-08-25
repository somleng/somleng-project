module "public_ssl_certificate" {
  source = "../modules/ssl_certificate"

  domain_name = "*.somleng.org"
  subject_alternative_names = [
    "*.app.somleng.org",
    "*.app-staging.somleng.org",
  ]
  route53_zone = aws_route53_zone.somleng_org
}

module "internal_ssl_certificate" {
  source = "../modules/ssl_certificate"

  domain_name               = "*.somleng.org"
  subject_alternative_names = ["*.internal.somleng.org"]
  route53_zone              = aws_route53_zone.somleng_org
}

resource "aws_acm_certificate" "cdn_certificate" {
  domain_name       = "*.somleng.org"
  validation_method = "DNS"
  provider          = aws.us-east-1
}

resource "aws_acm_certificate" "naked_cdn_somleng_org" {
  domain_name       = "somleng.org"
  validation_method = "DNS"
  provider          = aws.us-east-1
}
