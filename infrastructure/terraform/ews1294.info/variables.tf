locals {
  terraform_bucket = "terraform.ews1294.info"
  vpc_name = "pin-production"

  twilreapi_major_ruby_version = "2.3"
  twilreapi_identifier = "twilreapi"
  twilreapi_url_host = "https://somleng.ews1294.info"
  twilreapi_db_master_password = "AQICAHh5ylDKuj3jGBOphV/NIPGWxWaKQ5XSe4/KMCjtwW8boQEcnR7BnH68i203YgnzCHi/AAAAeDB2BgkqhkiG9w0BBwagaTBnAgEAMGIGCSqGSIb3DQEHATAeBglghkgBZQMEAS4wEQQM/mMu7y/b3cYmnv+GAgEQgDVZ59Gz995YjX1SZ3YsgHg2i6NwcqQbSwjzOm+g5U98UvaZcodoBDE+ht6Gql7x9mbrE7Fi3g=="
  twilreapi_rails_master_key = "AQICAHh5ylDKuj3jGBOphV/NIPGWxWaKQ5XSe4/KMCjtwW8boQH8yUs4O6M24hSmrBkZMe2jAAAAfjB8BgkqhkiG9w0BBwagbzBtAgEAMGgGCSqGSIb3DQEHATAeBglghkgBZQMEAS4wEQQMtJFSalilQVqpDrkrAgEQgDtqyhqv/s2cRHiyWLSIqEn6JkTpN9RzhSkNchtAmwdFbcoLHfGGgfNqPaDEw4JmZEBzWlTMrOMd7ORYaA=="

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