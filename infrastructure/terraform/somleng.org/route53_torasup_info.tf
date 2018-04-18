resource "aws_route53_zone" "torasup_info" {
  name = "torasup.info."
}

# For GSuite
resource "aws_route53_record" "torasup_info_mx" {
  zone_id = "${aws_route53_zone.torasup_info.zone_id}"
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
resource "aws_route53_record" "torasup_info_txt" {
  zone_id = "${aws_route53_zone.torasup_info.zone_id}"
  name    = ""
  type    = "TXT"
  ttl     = "3600"

  records = [
    "google-site-verification=Kf691ZADEehIruLEaA9fEWXNFbt5e280fjX6fdfzCos",
  ]
}

# naked redirection bucket
resource "aws_s3_bucket" "torasup_info_redirection" {
  bucket = "torasup.info"
  acl    = "private"

  website {
    redirect_all_requests_to = "http://www.torasup.info"
  }
}

# naked redirection alias
resource "aws_route53_record" "torasup_info_alias" {
  zone_id = "${aws_route53_zone.torasup_info.zone_id}"
  name    = ""
  type    = "A"

  alias {
    name                   = "${aws_s3_bucket.torasup_info_redirection.website_domain}"
    zone_id                = "${aws_s3_bucket.torasup_info_redirection.hosted_zone_id}"
    evaluate_target_health = false
  }
}

### www CNAME
resource "aws_route53_record" "torasup_info_www" {
  zone_id = "${aws_route53_zone.torasup_info.zone_id}"
  name    = "www"
  type    = "CNAME"
  ttl     = "3600"

  records = [
    "torasup.herokuapp.com",
  ]
}
