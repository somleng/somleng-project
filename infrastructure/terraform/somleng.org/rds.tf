module "twilreapi_db" {
  source = "../modules/rds"

  env_identifier = "${local.twilreapi_identifier}"

  master_password = "${data.aws_ssm_parameter.twilreapi_db_master_password.value}"

  vpc_id               = "${module.vpc.vpc_id}"
  db_subnet_group_name = "${module.vpc.database_subnet_group}"
}
