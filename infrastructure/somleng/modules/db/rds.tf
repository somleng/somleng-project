resource "aws_db_subnet_group" "this" {
  name        = local.database_identifier
  description = "For Aurora cluster ${local.database_identifier}"
  subnet_ids  = var.region.vpc.database_subnets

  tags = {
    Name = "aurora-${local.database_identifier}"
  }
}

resource "aws_rds_cluster" "this" {
  cluster_identifier              = local.database_identifier
  engine                          = "aurora-postgresql"
  engine_mode                     = "provisioned"
  engine_version                  = var.engine_version
  master_username                 = var.database_username
  apply_immediately               = true
  allow_major_version_upgrade     = true
  master_password                 = aws_ssm_parameter.db_master_password.value
  vpc_security_group_ids          = [aws_security_group.this.id]
  db_subnet_group_name            = aws_db_subnet_group.this.name
  skip_final_snapshot             = true
  storage_encrypted               = true
  enabled_cloudwatch_logs_exports = ["postgresql"]

  serverlessv2_scaling_configuration {
    max_capacity = var.max_capacity
    min_capacity = var.min_capacity
  }

  depends_on = [aws_cloudwatch_log_group.this]

  lifecycle {
    ignore_changes = [engine_version]
  }
}

resource "aws_rds_cluster_instance" "this" {
  identifier         = local.database_identifier
  cluster_identifier = aws_rds_cluster.this.id
  instance_class     = "db.serverless"
  engine             = aws_rds_cluster.this.engine
  engine_version     = aws_rds_cluster.this.engine_version
}
