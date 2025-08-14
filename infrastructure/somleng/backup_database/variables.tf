variable "aws_default_region" {
  default = "ap-southeast-1"
}

variable "backup_db" {
  description = "y or n"
}

variable "db_name" {
  description = "somleng or scfm"
}

variable "cluster_identifier" {
  description = "somlengv2 or open-ews"
}

variable "db_master_password_parameter_identifier" {
  description = "somleng or open-ews"
}
