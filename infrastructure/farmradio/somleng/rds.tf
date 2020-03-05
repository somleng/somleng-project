locals {
  database_port = 5432
}

resource "aws_security_group" "db" {
  name   = "somleng-rds"
  vpc_id = module.vpc.vpc_id

  ingress {
    from_port = local.database_port
    to_port   = local.database_port
    protocol  = "TCP"
    self      = true
  }
}

module "db" {
  source = "terraform-aws-modules/rds/aws"

  identifier = "somleng"

  engine                      = "postgres"
  engine_version              = "11.5"
  major_engine_version        = "11"
  instance_class              = "db.t3.micro"
  allow_major_version_upgrade = true
  auto_minor_version_upgrade  = true
  apply_immediately           = true
  storage_encrypted           = true

  allocated_storage = 5

  username = "postgres"
  password = aws_ssm_parameter.somleng_db_master_password.value
  port     = local.database_port

  vpc_security_group_ids = [aws_security_group.db.id]

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