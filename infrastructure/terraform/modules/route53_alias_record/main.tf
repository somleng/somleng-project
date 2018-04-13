resource "aws_route53_record" "record" {
  zone_id = "${var.hosted_zone_id}"
  name    = "${var.record_name}"
  type    = "A"

  alias {
    name                   = "${var.alias_dns_name}"
    zone_id                = "${var.alias_hosted_zone_id}"
    evaluate_target_health = false
  }
}
