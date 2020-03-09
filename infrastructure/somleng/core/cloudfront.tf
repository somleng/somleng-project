module "secure_headers" {
  source          = "../../modules/secure_headers"
  lambda_role_arn = aws_iam_role.secure_headers.arn

  providers = {
    aws = "aws.us-east-1"
  }
}

resource "aws_cloudfront_distribution" "distribution" {
  origin {
    domain_name = aws_s3_bucket.somleng_website.website_endpoint
    origin_id   = aws_s3_bucket.somleng_website.website_endpoint

    custom_origin_config {
      http_port              = "80"
      https_port             = "443"
      origin_protocol_policy = "http-only"
      origin_ssl_protocols   = ["TLSv1.2"]
    }
  }

  aliases = ["www.somleng.org"]

  enabled         = true
  is_ipv6_enabled = false

  logging_config {
    include_cookies = false
    bucket          = aws_s3_bucket.logs.bucket_domain_name
    prefix          = "cloudfront/${aws_s3_bucket.somleng_website.website_endpoint}"
  }

  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = aws_s3_bucket.somleng_website.website_endpoint

    viewer_protocol_policy = "redirect-to-https"
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
        "Host"
      ]
    }

    lambda_function_association {
      event_type   = "origin-response"
      lambda_arn   = var.lambda_qualified_arn
      include_body = false
    }
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    acm_certificate_arn      = var.acm_certificate_arn
    ssl_support_method       = "sni-only"
    minimum_protocol_version = "TLSv1.2_2018"
  }
}

module "somleng_website" {
  source = "../../modules/cloudfront"

  domain_name             = aws_s3_bucket.website.website_endpoint
  aliases                 = ["www.somleng.org"]
  origin_protocol_policy  = "http-only"
  acm_certificate_arn     = aws_acm_certificate.cdn_certificate.arn
  lambda_qualified_arn    = module.secure_headers.lambda_qualified_arn
  logs_bucket_domain_name = aws_s3_bucket.logs.bucket_domain_name
}

module "somleng_naked_redirect" {
  source = "../../modules/cloudfront"

  domain_name             = aws_s3_bucket.somleng_org_redirection.website_endpoint
  aliases                 = ["somleng.org"]
  origin_protocol_policy  = "http-only"
  acm_certificate_arn     = aws_acm_certificate.root_cdn_certificate.arn
  lambda_qualified_arn    = module.secure_headers.lambda_qualified_arn
  logs_bucket_domain_name = aws_s3_bucket.logs.bucket_domain_name
}
