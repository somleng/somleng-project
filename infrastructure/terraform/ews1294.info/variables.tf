locals {
  terraform_bucket = "terraform.ews1294.info"
  vpc_name = "pin-production"
  eb_zone_id         = "Z16FZ9L249IFLT"
  # For ap-southeast-1. See complete list: http://amzn.to/2E5LUdw
  twilreapi_major_ruby_version = "2.5"
  twilreapi_identifier = "somleng-twilreapi"
  twilreapi_url_host = "https://somleng.ews1294.info"
  twilreapi_route53_record_name = "somleng"
  twilreapi_db_master_password = "AQICAHh5ylDKuj3jGBOphV/NIPGWxWaKQ5XSe4/KMCjtwW8boQEXQB916s9eTm27WPFvO7D1AAAAfjB8BgkqhkiG9w0BBwagbzBtAgEAMGgGCSqGSIb3DQEHATAeBglghkgBZQMEAS4wEQQMoaT4QaCnv6YCkoOCAgEQgDsDP2Vu4howWLbVsSLAH91oXEJpe23yGP1QPcR8Rd49x3Ef1nn37P4uWTfLmSQbwUO9VrpoYVewcTzbrw=="
  twilreapi_rails_master_key = "AQICAHh5ylDKuj3jGBOphV/NIPGWxWaKQ5XSe4/KMCjtwW8boQH8yUs4O6M24hSmrBkZMe2jAAAAfjB8BgkqhkiG9w0BBwagbzBtAgEAMGgGCSqGSIb3DQEHATAeBglghkgBZQMEAS4wEQQMtJFSalilQVqpDrkrAgEQgDtqyhqv/s2cRHiyWLSIqEn6JkTpN9RzhSkNchtAmwdFbcoLHfGGgfNqPaDEw4JmZEBzWlTMrOMd7ORYaA=="
  # change me when somleng-adhearsion is terraformed
  twilreapi_outbound_call_drb_uri = "druby://somleng-production.ap-southeast-1.elasticbeanstalk.com:9050"

  scfm_major_ruby_version = "2.5"
  scfm_identifier = "scfm"
  # scfm_db_master_password =
  # scfm_rails_master_key =
}

variable "aws_region" {
  default = "ap-southeast-1"
}

variable "terraform_profile" {
  default = "ews1294-terraform"
}
