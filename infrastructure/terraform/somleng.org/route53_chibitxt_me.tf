resource "aws_route53_zone" "chibitxt_me" {
  name = "chibitxt.me."
}

# For GSuite
resource "aws_route53_record" "chibitxt_me_mx" {
  zone_id = "${aws_route53_zone.chibitxt_me.zone_id}"
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
resource "aws_route53_record" "chibitxt_me_txt" {
  zone_id = "${aws_route53_zone.chibitxt_me.zone_id}"
  name    = ""
  type    = "TXT"
  ttl     = "3600"

  records = [
    "google-site-verification=7X8SfDEZR43b-GLRsJ-d5zF0ObrWv6lkI2duG_ygMIo",
  ]
}

# naked redirection bucket
resource "aws_s3_bucket" "chibitxt_me_redirection" {
  bucket = "chibitxt.me"
  acl    = "private"

  website {
    redirect_all_requests_to = "http://www.chibitxt.me"
  }
}

# naked redirection alias
resource "aws_route53_record" "chibitxt_me_alias" {
  zone_id = "${aws_route53_zone.chibitxt_me.zone_id}"
  name    = ""
  type    = "A"

  alias {
    name                   = "${aws_s3_bucket.chibitxt_me_redirection.website_domain}"
    zone_id                = "${aws_s3_bucket.chibitxt_me_redirection.hosted_zone_id}"
    evaluate_target_health = false
  }
}

# www redirection bucket
resource "aws_s3_bucket" "chibitxt_me_www_redirection" {
  bucket = "www.chibitxt.me"
  acl    = "private"

  website {
    redirect_all_requests_to = "http://www.somleng.org"
  }
}

# www redirection alias
resource "aws_route53_record" "chibitxt_me_www_alias" {
  zone_id = "${aws_route53_zone.chibitxt_me.zone_id}"
  name    = "www"
  type    = "A"

  alias {
    name                   = "${aws_s3_bucket.chibitxt_me_www_redirection.website_domain}"
    zone_id                = "${aws_s3_bucket.chibitxt_me_www_redirection.hosted_zone_id}"
    evaluate_target_health = false
  }
}
