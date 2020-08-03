locals {
  database_port = 5432
  database_identifier = "somleng"
}

resource "aws_security_group" "db" {
  name   = "somleng"
  vpc_id = module.vpc.vpc_id

  ingress {
    from_port = local.database_port
    to_port   = local.database_port
    protocol  = "TCP"
    self      = true
  }
}

resource "aws_db_subnet_group" "this" {
  name        = "somleng-db"
  description = "For Aurora cluster somleng"
  subnet_ids  = module.vpc.database_subnets

  tags = {
    Name = "aurora-somleng"
  }
}

resource "aws_ssm_parameter" "db_master_password" {
  name  = "somleng.db_master_password"
  type  = "SecureString"
  value = "change-me"

  lifecycle {
    ignore_changes = [value]
  }
}

module "db" {
  source  = "terraform-aws-modules/rds-aurora/aws"

  name = local.database_identifier

  engine                      = "aurora-postgresql"
  engine_version              = "11.7"
  vpc_id = module.vpc.vpc_id
  db_subnet_group_name = aws_db_subnet_group.this.name
  allowed_security_groups = [aws_security_group.db.id]
  allowed_cidr_blocks = [module.vpc.vpc_cidr_block]
  instance_type              = "db.t3.medium"
  auto_minor_version_upgrade  = true
  apply_immediately           = true
  storage_encrypted           = true

  username = "somleng"
  password = aws_ssm_parameter.db_master_password.value
  port     = local.database_port
  enabled_cloudwatch_logs_exports = ["postgresql"]
}