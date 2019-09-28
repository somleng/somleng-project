resource "aws_cloudfront_distribution" "distribution" {
  # Note: When changing the configuration of cloudfront remember to manually invalidate the cache  # on CloudFront using the console. Otherwise the old config will be cached.

  # When cloudfront is updating don't make requests. This may cause caching of the error message which will  # require you to invalidate the cache once again.

  origin {
    domain_name = "${var.domain_name}"
    origin_id   = "${var.domain_name}"

    custom_origin_config {
      http_port              = "80"
      https_port             = "443"
      origin_protocol_policy = "${var.origin_protocol_policy}"
      origin_ssl_protocols   = "${var.origin_ssl_protocols}"
    }
  }

  aliases = "${var.aliases}"

  enabled         = true
  is_ipv6_enabled = false

  logging_config {
    include_cookies = false
    bucket          = "${var.logs_bucket_domain_name}"
    prefix          = "cloudfront/${var.domain_name}"
  }

  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = "${var.domain_name}"

    viewer_protocol_policy = "${var.viewer_protocol_policy}"
    min_ttl                = 0
    default_ttl            = 86400
    max_ttl                = 31536000

    forwarded_values {
      query_string = false

      cookies {
        forward = "none"
      }

      headers = [
        "Access-Control-Allow-Origin",
        "Access-Control-Allow-Headers",
        "Access-Control-Allow-Methods",
        "Access-Control-Max-Age",
        "Host",
      ]
    }

    lambda_function_association {
      event_type   = "origin-response"
      lambda_arn   = "${var.lambda_qualified_arn}"
      include_body = false
    }
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    acm_certificate_arn      = "${var.acm_certificate_arn}"
    ssl_support_method       = "sni-only"
    minimum_protocol_version = "TLSv1.2_2018"
  }
}

