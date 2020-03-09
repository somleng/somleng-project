# For GSuite
resource "aws_route53_record" "somleng_org_mx" {
  zone_id = "${aws_route53_zone.somleng_org.zone_id}"
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
  zone_id = "${aws_route53_zone.somleng_org.zone_id}"
  name    = ""
  type    = "TXT"
  ttl     = "3600"

  records = [
    "google-site-verification=rTfaXAmUN4J7FWHKFGg--fFAv3_Gj9nyGrdA2MsOqbU",
  ]
}

# naked redirection bucket
resource "aws_s3_bucket" "somleng_org_redirection" {
  bucket = "somleng.org"
  acl    = "private"

  website {
    redirect_all_requests_to = "https://www.somleng.org"
  }
}

module "route53_record_somleng_org" {
  source = "../../modules/route53_alias_record"

  hosted_zone_id       = "${aws_route53_zone.somleng_org.zone_id}"
  record_name          = ""
  alias_dns_name       = "${module.somleng_naked_redirect.domain_name}"
  alias_hosted_zone_id = "${module.somleng_naked_redirect.hosted_zone_id}"
}

module "route53_record_somleng_org_www" {
  source = "../../modules/route53_alias_record"

  hosted_zone_id       = "${aws_route53_zone.somleng_org.zone_id}"
  record_name          = "www"
  alias_dns_name       = "${module.somleng_website.domain_name}"
  alias_hosted_zone_id = "${module.somleng_website.hosted_zone_id}"
}
