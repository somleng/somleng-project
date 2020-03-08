resource "aws_route53_zone" "farmradio_io" {
  name = "farmradio.io."
}

resource "aws_route53_zone" "farmradio_io_internal" {
  name = "internal.farmradio.io."

  vpc {
    vpc_id = data.terraform_remote_state.somleng.outputs.vpc.vpc_id
  }
}

resource "aws_route53_record" "naked_redirect" {
  zone_id = aws_route53_zone.farmradio_io.zone_id
  name    = ""
  type    = "A"

  alias {
    name                   = aws_s3_bucket.naked_redirect.website_domain
    zone_id                = aws_s3_bucket.naked_redirect.hosted_zone_id
    evaluate_target_health = true
  }
}

resource "aws_route53_record" "www_redirect" {
  zone_id = aws_route53_zone.farmradio_io.zone_id
  name    = "www"
  type    = "A"

  alias {
    name                   = aws_s3_bucket.www_redirect.website_domain
    zone_id                = aws_s3_bucket.www_redirect.hosted_zone_id
    evaluate_target_health = true
  }
}