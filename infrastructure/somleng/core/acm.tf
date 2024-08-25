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
