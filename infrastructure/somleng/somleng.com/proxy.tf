module "dashboard_proxy" {
  source = "github.com/somleng/terraform-aws-cloudfront-reverse-proxy"

  host = "dashboard.somleng.com"
  origin = "demo-carrier.app.somleng.org"

  origin_custom_headers = [
    {
      "name" = "X-Forwarded-Host",
      "value" = "dashboard.somleng.com"
    }
  ]

  zone_id = aws_route53_zone.somleng_com.zone_id
  certificate_arn = aws_acm_certificate.this.arn
}

module "api_proxy" {
  source = "github.com/somleng/terraform-aws-cloudfront-reverse-proxy"
  host = "api.somleng.com"
  origin = "api.somleng.org"

  zone_id = aws_route53_zone.somleng_com.zone_id
  certificate_arn = aws_acm_certificate.this.arn
}