resource "aws_db_subnet_group" "twilreapi" {
  name       = "default-vpc-93669bf7"
  subnet_ids = ["${module.pin_vpc.database_subnets}"]
}

module "twilreapi_db" {
  source = "../modules/rds"

  env_identifier  = "${local.twilreapi_identifier}"
  master_password = "${data.aws_kms_secret.this.twilreapi_db_master_password}"

  vpc_id               = "${module.pin_vpc.vpc_id}"
  db_subnet_group_name = "${aws_db_subnet_group.twilreapi.name}"

  # PIN Specific Options
  identifier                 = "twilreapi-pin-production"
  username                   = "twilreapi"
  security_group_name        = "rds-launch-wizard-1"
  security_group_description = "Created from the RDS Management Console"
  engine_version             = "9.5.10"
  allocated_storage          = 20
}
