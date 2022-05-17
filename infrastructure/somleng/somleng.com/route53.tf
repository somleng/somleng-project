resource "aws_route53_zone" "somleng_com" {
  name = "somleng.com"
}

resource "aws_route53_record" "somleng_com" {
  zone_id = aws_route53_zone.somleng_com.zone_id
  name    = ""
  type    = "A"

  alias {
    name                   = aws_s3_bucket.somleng_com.website_domain
    zone_id                = aws_s3_bucket.somleng_com.hosted_zone_id
    evaluate_target_health = true
  }
}

resource "aws_route53_record" "www_somleng_com" {
  zone_id = aws_route53_zone.somleng_com.zone_id
  name    = "www"
  type    = "A"

  alias {
    name                   = aws_s3_bucket.www_somleng_com.website_domain
    zone_id                = aws_s3_bucket.www_somleng_com.hosted_zone_id
    evaluate_target_health = true
  }
}

resource "aws_route53_record" "somleng_com_mx" {
  zone_id = aws_route53_zone.somleng_com.zone_id
  name    = ""
  type    = "MX"
  ttl     = "3600"

  records = [
    "1 ASPMX.L.GOOGLE.COM",
    "5 ALT1.ASPMX.L.GOOGLE.COM",
    "5 ALT2.ASPMX.L.GOOGLE.COM",
    "10 ALT3.ASPMX.L.GOOGLE.COM",
    "10 ALT4.ASPMX.L.GOOGLE.COM",
  ]
}

resource "aws_route53_record" "somleng_com_txt" {
  zone_id = aws_route53_zone.somleng_com.zone_id
  name    = ""
  type    = "TXT"
  ttl     = "3600"

  records = [
    "google-site-verification=H1Qxp7StJYRB32sBQE6jlWECLB3sqT_EeJwZcs4bpwE",
  ]
}

# Somleng Custom Domain Verification

resource "aws_route53_record" "somleng_dashboard_txt" {
  zone_id = aws_route53_zone.somleng_com.zone_id
  name    = "dashboard"
  type    = "TXT"
  ttl     = "3600"

  records = [
    "somleng-domain-verification=kstqpSQoJzbL3KNW8SbR7UfE",
  ]
}

resource "aws_route53_record" "somleng_api_txt" {
  zone_id = aws_route53_zone.somleng_com.zone_id
  name    = "api"
  type    = "TXT"
  ttl     = "3600"

  records = [
    "somleng-domain-verification=18JDHSpuT1rLM5TbaGLhLrbh",
  ]
}

resource "aws_route53_record" "somleng_mail_cname_1" {
  zone_id = aws_route53_zone.somleng_com.zone_id
  name    = "frjyz4k46rhxu4lg6ewhesy72cqqit3h._domainkey"
  type    = "CNAME"
  ttl     = "3600"

  records = [
    "frjyz4k46rhxu4lg6ewhesy72cqqit3h.dkim.amazonses.com",
  ]
}

resource "aws_route53_record" "somleng_mail_cname_2" {
  zone_id = aws_route53_zone.somleng_com.zone_id
  name    = "gnsrbeh7jbjkzuajdksgb27s7yvv3oo2._domainkey.somleng.com"
  type    = "CNAME"
  ttl     = "3600"

  records = [
    "gnsrbeh7jbjkzuajdksgb27s7yvv3oo2.dkim.amazonses.com",
  ]
}

resource "aws_route53_record" "somleng_mail_cname_3" {
  zone_id = aws_route53_zone.somleng_com.zone_id
  name    = "diaftrbc3kkywd5n5yj6mfrk2me44ifd._domainkey.somleng.com"
  type    = "CNAME"
  ttl     = "3600"

  records = [
    "diaftrbc3kkywd5n5yj6mfrk2me44ifd.dkim.amazonses.com",
  ]
}
