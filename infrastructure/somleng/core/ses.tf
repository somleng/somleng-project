resource "aws_ses_domain_identity" "domain" {
  domain   = "somleng.org"
  provider = aws.us-east-1
}

resource "aws_ses_domain_mail_from" "mail_from" {
  domain           = aws_ses_domain_identity.domain.domain
  mail_from_domain = "mail.${aws_ses_domain_identity.domain.domain}"
  provider         = aws.us-east-1
}

resource "aws_ses_domain_identity_verification" "verification" {
  domain     = aws_ses_domain_identity.domain.id
  provider   = aws.us-east-1
  depends_on = [aws_route53_record.amazonses_verification_record]
}

resource "aws_ses_domain_dkim" "dkim" {
  domain   = aws_ses_domain_identity.domain.domain
  provider = aws.us-east-1
}

resource "aws_route53_record" "dkim_amazonses_verification_record" {
  count   = 3
  zone_id = aws_route53_zone.somleng_org.zone_id
  name    = "${element(aws_ses_domain_dkim.dkim.dkim_tokens, count.index)}._domainkey.somleng.org"
  type    = "CNAME"
  ttl     = "600"
  records = ["${element(aws_ses_domain_dkim.dkim.dkim_tokens, count.index)}.dkim.amazonses.com"]
}

resource "aws_route53_record" "ses_domain_mail_from_mx" {
  zone_id = aws_route53_zone.somleng_org.zone_id
  name    = aws_ses_domain_mail_from.mail_from.mail_from_domain
  type    = "MX"
  ttl     = "600"
  records = ["10 feedback-smtp.us-east-1.amazonses.com"]
}

resource "aws_route53_record" "spf_ses_domain_mail_from_txt" {
  zone_id = aws_route53_zone.somleng_org.zone_id
  name    = aws_ses_domain_mail_from.mail_from.mail_from_domain
  type    = "TXT"
  ttl     = "600"
  records = ["v=spf1 include:amazonses.com -all"]
}

resource "aws_route53_record" "amazonses_verification_record" {
  zone_id = aws_route53_zone.somleng_org.zone_id
  name    = "_amazonses"
  type    = "TXT"
  ttl     = "600"
  records = [
    aws_ses_domain_identity.domain.verification_token
  ]
}

resource "aws_route53_record" "dmarc_record" {
  zone_id = aws_route53_zone.somleng_org.zone_id
  name    = "_dmarc"
  type    = "TXT"
  ttl     = "600"
  records = ["v=DMARC1;p=none"]
}
