resource "aws_route53_zone" "ews1294_info" {
  name = "${local.route53_domain_name}."
}

module "route53_record_somleng_twilreapi" {
  source = "../modules/route53_alias_record"

  hosted_zone_id       = "${aws_route53_zone.ews1294_info.zone_id}"
  record_name          = "${local.twilreapi_route53_record_name}"
  alias_dns_name       = "${module.twilreapi_eb_app_env.web_cname}"
  alias_hosted_zone_id = "${local.eb_zone_id}"
}

module "route53_record_scfm" {
  source = "../modules/route53_alias_record"

  hosted_zone_id       = "${aws_route53_zone.ews1294_info.zone_id}"
  record_name          = "${local.scfm_route53_record_name}"
  alias_dns_name       = "${module.scfm_eb_app_env.web_cname}"
  alias_hosted_zone_id = "${local.eb_zone_id}"
}
