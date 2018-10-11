resource "aws_acm_certificate" "unicef_io" {
  domain_name       = "*.unicef.io"
  validation_method = "DNS"

  lifecycle {
    create_before_destroy = true
  }
}
