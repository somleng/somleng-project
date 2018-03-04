resource "aws_route53_zone" "somleng_com" {
  name = "somleng.com."
}

# For GSuite
resource "aws_route53_record" "somleng_com_mx" {
  zone_id = "${aws_route53_zone.somleng_com.zone_id}"
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
resource "aws_route53_record" "somleng_com_txt" {
  zone_id = "${aws_route53_zone.somleng_com.zone_id}"
  name    = ""
  type    = "TXT"
  ttl     = "3600"

  records = [
    "google-site-verification=H1Qxp7StJYRB32sBQE6jlWECLB3sqT_EeJwZcs4bpwE"
  ]
}

# naked redirection bucket
resource "aws_s3_bucket" "somleng_com_redirection" {
  bucket = "somleng.com"
  acl    = "private"

  website {
    redirect_all_requests_to = "http://www.somleng.com"
  }
}

# naked redirection alias
resource "aws_route53_record" "somleng_com_alias" {
  zone_id = "${aws_route53_zone.somleng_com.zone_id}"
  name    = ""
  type    = "A"

  alias {
    name                   = "${aws_s3_bucket.somleng_com_redirection.website_domain}"
    zone_id                = "${aws_s3_bucket.somleng_com_redirection.hosted_zone_id}"
    evaluate_target_health = false
  }
}

# www redirection bucket
resource "aws_s3_bucket" "somleng_com_www_redirection" {
  bucket = "www.somleng.com"
  acl    = "private"

  website {
    redirect_all_requests_to = "http://www.somleng.org"
  }
}

# www redirection alias
resource "aws_route53_record" "somleng_com_www_alias" {
  zone_id = "${aws_route53_zone.somleng_com.zone_id}"
  name    = "www"
  type    = "A"

  alias {
    name                   = "${aws_s3_bucket.somleng_com_www_redirection.website_domain}"
    zone_id                = "${aws_s3_bucket.somleng_com_www_redirection.hosted_zone_id}"
    evaluate_target_health = false
  }
}
