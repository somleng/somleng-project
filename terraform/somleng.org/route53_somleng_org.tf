resource "aws_route53_zone" "somleng_org" {
  name = "somleng.org."
}

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
    "10 ALT4.ASPMX.L.GOOGLE.COM"
  ]
}

# For GSuite
resource "aws_route53_record" "somleng_org_txt" {
  zone_id = "${aws_route53_zone.somleng_org.zone_id}"
  name    = ""
  type    = "TXT"
  ttl     = "3600"

  records = [
    "google-site-verification=rTfaXAmUN4J7FWHKFGg--fFAv3_Gj9nyGrdA2MsOqbU"
  ]
}

resource "aws_route53_record" "somleng_org_www" {
  zone_id = "${aws_route53_zone.somleng_org.zone_id}"
  name    = "www"
  type    = "CNAME"
  ttl     = "3600"

  records = [
    "dwilkie.github.io"
  ]
}

resource "aws_route53_record" "somlng_org_rtd" {
  zone_id = "${aws_route53_zone.somleng_org.zone_id}"
  name    = "rtd"
  type    = "CNAME"
  ttl     = "3600"

  records = [
    "somleng-rtd.herokuapp.com"
  ]
}
