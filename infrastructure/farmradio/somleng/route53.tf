data "aws_elastic_beanstalk_hosted_zone" "current" {}

resource "aws_route53_record" "twilreapi" {
  zone_id = data.terraform_remote_state.core.outputs.farmradio_zone.id
  name    = "twilreapi"
  type    = "A"

  alias {
    name                   = aws_elastic_beanstalk_environment.twilreapi_webserver.cname
    zone_id                = data.aws_elastic_beanstalk_hosted_zone.current.id
    evaluate_target_health = true
  }
}

resource "aws_route53_record" "somleng_adhearsion" {
  zone_id = data.terraform_remote_state.core.outputs.farmradio_internal_zone.id
  name    = "somleng-adhearsion"
  type    = "A"

  alias {
    name                   = aws_elastic_beanstalk_environment.somleng_adhearsion_webserver.cname
    zone_id                = data.aws_elastic_beanstalk_hosted_zone.current.id
    evaluate_target_health = true
  }
}

resource "aws_route53_record" "somleng_freeswitch" {
  zone_id = data.terraform_remote_state.core.outputs.farmradio_internal_zone.id
  name    = "freeswitch"
  type    = "A"

  alias {
    name                   = aws_elastic_beanstalk_environment.freeswitch_webserver.cname
    zone_id                = data.aws_elastic_beanstalk_hosted_zone.current.id
    evaluate_target_health = true
  }
}