locals {
  database_port = 5432
  identifier = "somlengv2"
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

resource "aws_db_subnet_group" "db_old" {
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

module "db_old" {
  source  = "terraform-aws-modules/rds-aurora/aws"
  security_group_description = "Managed by Terraform"

  name = "somleng"

  engine            = "aurora-postgresql"
  engine_mode       = "serverless"
  engine_version    = null
  vpc_id = module.vpc.vpc_id
  db_subnet_group_name = aws_db_subnet_group.db_old.name
  create_db_subnet_group = false
  allowed_security_groups = [aws_security_group.db.id]
  allowed_cidr_blocks = [module.vpc.vpc_cidr_block]
  auto_minor_version_upgrade  = true
  apply_immediately           = true
  storage_encrypted           = true
  monitoring_interval = 60

  master_username = "somleng"
  master_password = aws_ssm_parameter.db_master_password.value
  create_random_password = false
  port     = local.database_port

  scaling_configuration = {
    auto_pause               = true
    min_capacity             = 2
    max_capacity             = 64
    seconds_until_auto_pause = 600
    timeout_action           = "ForceApplyCapacityChange"
  }
}

resource "aws_db_subnet_group" "db" {
  name        = local.identifier
  description = "For Aurora cluster ${local.identifier}"
  subnet_ids  = module.vpc.database_subnets

  tags = {
    Name = "aurora-${local.identifier}"
  }
}

resource "aws_rds_cluster" "db" {
  cluster_identifier = local.identifier
  engine             = "aurora-postgresql"
  engine_mode        = "provisioned"
  engine_version     = "13.6"
  master_username    = "somleng"
  master_password    = aws_ssm_parameter.db_master_password.value
  vpc_security_group_ids = [aws_security_group.db.id]
  db_subnet_group_name   = aws_db_subnet_group.db.name
  skip_final_snapshot = true
  storage_encrypted = true

  serverlessv2_scaling_configuration {
    max_capacity = 2.0
    min_capacity = 0.5
  }
}

resource "aws_rds_cluster_instance" "db" {
  identifier = local.identifier
  cluster_identifier = aws_rds_cluster.db.id
  instance_class     = "db.serverless"
  engine             = aws_rds_cluster.db.engine
  engine_version     = aws_rds_cluster.db.engine_version
}
