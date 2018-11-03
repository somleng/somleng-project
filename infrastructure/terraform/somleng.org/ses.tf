module "ses" {
  source              = "../modules/ses"
  zone_id             = "${aws_route53_zone.somleng_org.zone_id}"
  route53_domain_name = "${local.route53_domain_name}"
}
