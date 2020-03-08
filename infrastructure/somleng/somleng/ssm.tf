resource "aws_ssm_parameter" "twilreapi_rails_master_key" {
  name  = "twilreapi.rails.master_key"
  type  = "SecureString"
  value = "change-me"

  lifecycle {
    ignore_changes = [value]
  }
}

resource "aws_ssm_parameter" "twilreapi_db_master_password" {
  name  = "twilreapi.db.master_password"
  type  = "SecureString"
  value = "change-me"

  lifecycle {
    ignore_changes = [value]
  }
}

resource "aws_ssm_parameter" "somleng_freeswitch_mod_rayo_password" {
  name  = "freeswitch.mod_rayo.password"
  type  = "SecureString"
  value = "change-me"

  lifecycle {
    ignore_changes = [value]
  }
}

resource "aws_ssm_parameter" "freeswitch_mod_rayo_shared_secret" {
  name  = "freeswitch.mod_rayo.shared_secret"
  type  = "SecureString"
  value = "change-me"

  lifecycle {
    ignore_changes = [value]
  }
}

resource "aws_ssm_parameter" "twilreapi_internal_api_password" {
  name  = "twilreapi.rails.internal_api_http_auth_password"
  type  = "SecureString"
  value = "change-me"

  lifecycle {
    ignore_changes = [value]
  }
}