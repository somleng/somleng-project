resource "aws_route53_zone" "somleng_org" {
  name = "somleng.org."
}

resource "aws_route53_zone" "somleng_org_private" {
  name = "internal.somleng.org."

  vpc {
    vpc_id = module.vpc.vpc_id
  }

  vpc {
    vpc_id     = module.vpc_helium.vpc_id
    vpc_region = var.aws_helium_region
  }
}

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

resource "aws_route53_record" "somleng_org_txt" {
  zone_id = aws_route53_zone.somleng_org.zone_id
  name    = ""
  type    = "TXT"
  ttl     = "3600"

  records = [
    "google-site-verification=rTfaXAmUN4J7FWHKFGg--fFAv3_Gj9nyGrdA2MsOqbU",
  ]
}

resource "aws_route53_record" "somleng_org_github" {
  zone_id = aws_route53_zone.somleng_org.zone_id
  name    = "_github-challenge-somleng-org"
  type    = "TXT"
  ttl     = "3600"

  records = [
    "489c3122c7",
  ]
}

resource "aws_route53_record" "naked_redirect" {
  zone_id = aws_route53_zone.somleng_org.zone_id
  name    = ""
  type    = "A"

  alias {
    name                   = aws_cloudfront_distribution.somleng_naked_redirect.domain_name
    zone_id                = aws_cloudfront_distribution.somleng_naked_redirect.hosted_zone_id
    evaluate_target_health = true
  }
}

resource "aws_route53_record" "somleng_website" {
  zone_id = aws_route53_zone.somleng_org.zone_id
  name    = "www"
  type    = "A"

  alias {
    name                   = aws_cloudfront_distribution.somleng_website.domain_name
    zone_id                = aws_cloudfront_distribution.somleng_website.hosted_zone_id
    evaluate_target_health = true
  }
}
