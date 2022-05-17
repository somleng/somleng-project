module "dashboard_proxy" {
  source = "github.com/somleng/terraform-aws-cloudfront-reverse-proxy"

  origin_domain_name = "dashboard.somleng.org"
  domain_name = aws_route53_zone.somleng_com.name
  host_name = "dashboard"
  zone_id = aws_route53_zone.somleng_com.zone_id

  create_certificate = false
  certificate_arn = aws_acm_certificate.this.arn
}

module "api_proxy" {
  source = "github.com/somleng/terraform-aws-cloudfront-reverse-proxy"

  origin_domain_name = "api.somleng.org"
  domain_name = aws_route53_zone.somleng_com.name
  host_name = "api"
  zone_id = aws_route53_zone.somleng_com.zone_id

  create_certificate = false
  certificate_arn = aws_acm_certificate.this.arn
}
