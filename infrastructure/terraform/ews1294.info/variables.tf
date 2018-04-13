locals {
  terraform_bucket = "terraform.ews1294.info"
  vpc_name = "pin-production"

  twilreapi_major_ruby_version = "2.3"
  twilreapi_identifier = "twilreapi"
  twilreapi_db_master_password = "AQICAHh5ylDKuj3jGBOphV/NIPGWxWaKQ5XSe4/KMCjtwW8boQGkZa79U3u9hIulM8gTumxvAAAAeTB3BgkqhkiG9w0BBwagajBoAgEAMGMGCSqGSIb3DQEHATAeBglghkgBZQMEAS4wEQQMcdNxLrmOwYRIcBnsAgEQgDZFsax1G6GwEve74y3rtdjpH9dM1DBcoqZUa2EsE1GSRqbVMXgVMBLphYU2Gnfi+DSQFoxBZE0="
  # twilreapi_rails_master_key =

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
