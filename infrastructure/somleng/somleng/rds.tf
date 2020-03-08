locals {
  database_port = 5432
}

  resource "aws_security_group" "twilreapi_db" {
  name   = "somleng-twilreapi-rds"
  vpc_id = module.vpc.vpc_id

  ingress {
    from_port = local.database_port
    to_port   = local.database_port
    protocol  = "TCP"
    self      = true
  }
}

module "twilreapi_db" {
  source = "terraform-aws-modules/rds/aws"

  identifier = "somleng-twilreapi"
  name = "somleng_twilreapi"

  engine                      = "postgres"
  engine_version              = "11.5"
  major_engine_version        = "11"
  instance_class              = "db.t3.micro"
  allow_major_version_upgrade = true
  auto_minor_version_upgrade  = true
  apply_immediately           = true
  storage_encrypted           = false
  db_subnet_group_name = module.vpc.database_subnet_group

  allocated_storage = 5

  username = "somleng"
  password = aws_ssm_parameter.twilreapi_db_master_password.value
  port     = local.database_port

  vpc_security_group_ids = [aws_security_group.twilreapi_db.id]

  skip_final_snapshot       = false
  final_snapshot_identifier = "somleng"
  backup_retention_period   = 30
  maintenance_window        = "Sun:19:00-Sun:22:00"
  backup_window             = "22:00-00:00"
  deletion_protection       = true
  multi_az                  = false

  enabled_cloudwatch_logs_exports = ["postgresql", "upgrade"]

  create_db_parameter_group = false
  subnet_ids                = module.vpc.database_subnets
}