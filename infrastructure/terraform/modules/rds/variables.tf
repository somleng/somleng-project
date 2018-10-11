variable "env_identifier" {}

variable "vpc_id" {
  description = "The ID of the VPC"
}

variable "master_password" {
  description = "DB master password"
}

variable "db_subnet_group_name" {
  description = "Name of DB subnet group. DB instance will be created in the VPC associated with the DB subnet group"
}

variable "engine" {
  default = "postgres"
}

variable "engine_version" {
  default = "9.6.6"
}

variable "allocated_storage" {
  default = 5
}

variable "port" {
  default = "5432"
}

variable "username" {
  default = "somleng"
}

variable "backup_retention_period" {
  default = 30
}

variable "maintenance_window" {
  default = "Sun:19:00-Sun:22:00"
}

variable "security_group_name" {
  default = ""
}

variable "identifier" {
  default = ""
}

variable "allow_major_version_upgrade" {
  default = true
}

variable "security_group_description" {
  default = "Managed by Terraform"
}

variable "backup_window" {
  default = "22:00-00:00"
}

variable "instance_class" {
  description = "The instance type of the RDS instance"
  default     = "db.t2.micro"
}

variable "multi_az" {
  description = "Specifies if the RDS instance is multi-AZ"
  default     = false
}

variable "storage_encrypted" {
  description = "Specifies whether the DB instance is encrypted"
  default     = false
}

variable "apply_immediately" {
  description = "Apply changes immediately"
  default     = true
}

variable "skip_final_snapshot" {
  description = "Determines whether a final DB snapshot is created before the DB instance is deleted. If true is specified, no DBSnapshot is created. If false is specified, a DB snapshot is created before the DB instance is deleted, using the value from final_snapshot_identifier"
  default     = true
}
