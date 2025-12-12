locals {
  database_identifier = var.database_identifier != "" ? var.database_identifier : var.identifier
}

data "aws_rds_cluster" "current" {
  cluster_identifier = local.database_identifier
}

variable "identifier" {}
variable "database_username" {}
variable "engine_version" {
  validation {
    condition     = var.engine_version >= data.aws_rds_cluster.current.engine_version
    error_message = "You are attempting to downgrade the engine version. Downgrades are not allowed."
  }
}
variable "region" {}
variable "database_port" {
  default = 5432
}
variable "database_identifier" {
  default = ""
}

variable "min_capacity" {
  default = 0.5
}

variable "max_capacity" {
  default = 64.0
}
