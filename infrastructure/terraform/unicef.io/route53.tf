resource "aws_route53_zone" "unicef_io" {
  name = "${local.route53_domain_name}."
}

resource "aws_route53_zone" "internal" {
  name   = "${local.internal_route53_domain_name}."
  vpc_id = "${module.vpc.vpc_id}"
}

module "route53_record_somleng_twilreapi" {
  source = "../modules/route53_alias_record"

  hosted_zone_id       = "${aws_route53_zone.unicef_io.zone_id}"
  record_name          = "${local.twilreapi_route53_record_name}"
  alias_dns_name       = "${module.twilreapi_eb_app_env.web_cname}"
  alias_hosted_zone_id = "${local.eb_zone_id}"
}

module "route53_record_somleng_adhearsion" {
  source = "../modules/route53_alias_record"

  hosted_zone_id       = "${aws_route53_zone.internal.zone_id}"
  record_name          = "${local.somleng_adhearsion_route53_record_name}"
  alias_dns_name       = "${module.somleng_adhearsion_webserver.cname}"
  alias_hosted_zone_id = "${local.eb_zone_id}"
}
