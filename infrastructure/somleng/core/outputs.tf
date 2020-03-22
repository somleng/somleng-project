output "acm_certificate" {
  value = aws_acm_certificate.certificate
}

output "somleng_zone" {
  value = aws_route53_zone.somleng_org
}

output "somleng_internal_zone" {
  value = aws_route53_zone.internal
}

output "ses_credentials" {
  value = aws_iam_access_key.ses_sender
}