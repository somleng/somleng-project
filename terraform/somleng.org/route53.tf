resource "aws_route53_zone" "somleng_org" {
  name = "somleng.org."
}

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
