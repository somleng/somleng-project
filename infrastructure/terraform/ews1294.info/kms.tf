resource "aws_kms_key" "master" {
  description         = "Master Key"
  enable_key_rotation = true

  tags {
    Name = "terraform-master-key"
  }
}

resource "aws_kms_alias" "master" {
  name          = "alias/pin-master"
  target_key_id = "${aws_kms_key.master.key_id}"
}

data "aws_kms_secret" "this" {
  secret {
    name    = "twilreapi_db_master_password"
    payload = "${local.twilreapi_db_master_password}"
  }

  secret {
    name    = "twilreapi_rails_master_key"
    payload = "${local.twilreapi_rails_master_key}"
  }

  secret {
    name    = "scfm_db_master_password"
    payload = "${local.scfm_db_master_password}"
  }

  secret {
    name    = "scfm_rails_master_key"
    payload = "${local.scfm_rails_master_key}"
  }
}
