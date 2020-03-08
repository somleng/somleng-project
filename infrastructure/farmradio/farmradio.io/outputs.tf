output "acm_certificate" {
  value = aws_acm_certificate.certificate
}

output "farmradio_zone" {
  value = aws_route53_zone.farmradio_io
}

output "farmradio_internal_zone" {
  value = aws_route53_zone.farmradio_io_internal
}