resource "aws_acm_certificate" "certificate" {
  domain_name       = "*.somleng.org"
  validation_method = "DNS"
  subject_alternative_names = ["*.app.somleng.org", "*.app-staging.somleng.org"]
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

# Additional certificates for the same domain don't require validations

resource "aws_route53_record" "certificate_validation" {
  for_each = {
    for dvo in aws_acm_certificate.certificate.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }

  allow_overwrite = true
  name            = each.value.name
  ttl     = 60
  records         = [each.value.record]
  type            = each.value.type
  zone_id = aws_route53_zone.somleng_org.zone_id
}

resource "aws_acm_certificate_validation" "certificate" {
  certificate_arn         = aws_acm_certificate.certificate.arn
  validation_record_fqdns = [for record in aws_route53_record.certificate_validation : record.fqdn]
}
