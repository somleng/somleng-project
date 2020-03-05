resource "aws_acm_certificate" "certificate" {
  domain_name       = "*.farmradio.io"
  validation_method = "DNS"
}

resource "aws_route53_record" "certificate_validation" {
  name    = aws_acm_certificate.certificate.domain_validation_options.0.resource_record_name
  type    = aws_acm_certificate.certificate.domain_validation_options.0.resource_record_type
  zone_id = aws_route53_zone.farmradio_io.zone_id
  records = [aws_acm_certificate.certificate.domain_validation_options.0.resource_record_value]
  ttl     = 60
}

resource "aws_acm_certificate_validation" "certificate" {
  certificate_arn         = aws_acm_certificate.certificate.arn
  validation_record_fqdns = [
    aws_route53_record.certificate_validation.fqdn
  ]
}
