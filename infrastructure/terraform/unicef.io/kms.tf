resource "aws_kms_key" "master" {
  description         = "Master Key"
  enable_key_rotation = true

  tags {
    Name = "terraform-master-key"
  }
}

resource "aws_kms_alias" "master" {
  name          = "alias/master"
  target_key_id = "${aws_kms_key.master.key_id}"
}

data "aws_kms_secrets" "secrets" {
  secret {
    name    = "twilreapi_db_master_password"
    payload = "${local.twilreapi_db_master_password}"
  }

  secret {
    name    = "twilreapi_rails_master_key"
    payload = "${local.twilreapi_rails_master_key}"
  }

  secret {
    name    = "somleng_freeswitch_mod_rayo_password"
    payload = "${local.somleng_freeswitch_mod_rayo_encrypted_password}"
  }

  secret {
    name    = "somleng_freeswitch_mod_rayo_shared_secret"
    payload = "${local.somleng_freeswitch_mod_rayo_encrypted_shared_secret}"
  }

  secret {
    name    = "twilreapi_internal_api_http_auth_password"
    payload = "${local.twilreapi_internal_api_http_auth_encrypted_password}"
  }
}
