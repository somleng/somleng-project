resource "aws_route53_zone" "somleng_org" {
  name = "somleng.org."
}

resource "aws_route53_zone" "internal" {
  name = "internal.somleng.org."

  vpc {
    vpc_id = data.terraform_remote_state.somleng.outputs.vpc.vpc_id
  }
}

# For GSuite
resource "aws_route53_record" "somleng_org_mx" {
  zone_id = aws_route53_zone.somleng_org.zone_id
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

# For GSuite
resource "aws_route53_record" "somleng_org_txt" {
  zone_id = aws_route53_zone.somleng_org.zone_id
  name    = ""
  type    = "TXT"
  ttl     = "3600"

  records = [
    "google-site-verification=rTfaXAmUN4J7FWHKFGg--fFAv3_Gj9nyGrdA2MsOqbU",
  ]
}

resource "aws_route53_record" "naked_redirect" {
  zone_id = aws_route53_zone.somleng_org.zone_id
  name    = ""
  type    = "A"

  alias {
    name                   = aws_s3_bucket.naked_redirect.website_domain
    zone_id                = aws_s3_bucket.naked_redirect.hosted_zone_id
    evaluate_target_health = true
  }
}

resource "aws_route53_record" "somleng_website" {
  zone_id = aws_route53_zone.somleng_org.zone_id
  name    = ""
  type    = "A"

  alias {
    name                   = aws_s3_bucket.somleng_website.website_domain
    zone_id                = aws_s3_bucket.somleng_website.hosted_zone_id
    evaluate_target_health = true
  }
}