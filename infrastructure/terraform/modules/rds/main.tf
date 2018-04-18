locals {
  identifier = "${var.identifier == "" ? "${var.env_identifier}" : "${var.identifier}"}"
}

locals {
  security_group_name = "${var.security_group_name == "" ? "${local.identifier}-rds" : "${var.security_group_name}"}"
}

resource "aws_security_group" "db" {
  name        = "${local.security_group_name}"
  description = "${var.security_group_description}"
  vpc_id      = "${var.vpc_id}"

  ingress {
    from_port = "${var.port}"
    to_port   = "${var.port}"
    protocol  = "TCP"
    self      = true
  }
}

module "db" {
  source = "terraform-aws-modules/rds/aws"

  identifier = "${local.identifier}"

  engine            = "${var.engine}"
  engine_version    = "${var.engine_version}"
  instance_class    = "${var.instance_class}"
  allocated_storage = "${var.allocated_storage}"
  multi_az          = "${var.multi_az}"
  storage_encrypted = "${var.storage_encrypted}"

  name     = "${replace(local.identifier, "-", "_")}"
  username = "${var.username}"
  password = "${var.master_password}"
  port     = "${var.port}"

  vpc_security_group_ids = ["${aws_security_group.db.id}"]
  db_subnet_group_name   = "${var.db_subnet_group_name}"

  skip_final_snapshot       = "${var.skip_final_snapshot}"
  final_snapshot_identifier = "${var.env_identifier}"
  backup_retention_period   = "${var.backup_retention_period}"
  maintenance_window        = "${var.maintenance_window}"
  backup_window             = "${var.backup_window}"

  allow_major_version_upgrade = "${var.allow_major_version_upgrade}"
  create_db_parameter_group   = false
}
