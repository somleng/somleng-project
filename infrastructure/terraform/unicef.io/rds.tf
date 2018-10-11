module "twilreapi_db" {
  source = "../modules/rds"

  env_identifier = "${local.twilreapi_identifier}"

  master_password = "${data.aws_kms_secrets.secrets.plaintext["twilreapi_db_master_password"]}"

  vpc_id               = "${module.vpc.vpc_id}"
  db_subnet_group_name = "${module.vpc.database_subnet_group}"

  # UNICEF Specific Options
  identifier = "twilreapi"
  username   = "twilreapi"
}
