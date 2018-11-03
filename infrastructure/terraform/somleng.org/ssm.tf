data "aws_ssm_parameter" "twilreapi_db_master_password" {
  name = "twilreapi.db.master_password"
}

data "aws_ssm_parameter" "twilreapi_rails_master_key" {
  name = "twilreapi.rails.master_key"
}

data "aws_ssm_parameter" "twilreapi_rails_internal_api_http_auth_password" {
  name = "twilreapi.rails.internal_api_http_auth_password"
}

data "aws_ssm_parameter" "freeswitch_mod_rayo_password" {
  name = "freeswitch.mod_rayo.password"
}

data "aws_ssm_parameter" "freeswitch_mod_rayo_shared_secret" {
  name = "freeswitch.mod_rayo.shared_secret"
}
