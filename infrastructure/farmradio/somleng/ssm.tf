resource "aws_ssm_parameter" "twilreapi_rails_master_key" {
  name  = "twilreapi.rails_master_key"
  type  = "SecureString"
  value = "change-me"

  lifecycle {
    ignore_changes = [value]
  }
}

resource "aws_ssm_parameter" "somleng_db_master_password" {
  name  = "somleng.db_master_password"
  type  = "SecureString"
  value = "change-me"

  lifecycle {
    ignore_changes = [value]
  }
}