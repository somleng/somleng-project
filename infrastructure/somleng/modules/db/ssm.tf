resource "aws_ssm_parameter" "db_master_password" {
  name  = "${var.identifier}.db_master_password"
  type  = "SecureString"
  value = "change-me"

  lifecycle {
    ignore_changes = [value]
  }
}
