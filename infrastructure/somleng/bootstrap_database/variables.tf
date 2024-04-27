variable "aws_region" {
  default = "ap-southeast-1"
}

variable "create_db" {
  description = "y or n"
}
variable "restore_db" {
  description = "y or n (BE CAREFUL! THIS WILL DROP THE DATABASE IF IN DOUBT SELECT 'n')"
}
variable "restore_db_from_backup_name" {
  description = "somleng"
}
variable "db_name" {
  description = "somleng"
}
variable "cluster_identifier" {
  description = "somlengv2"
}
variable "db_master_password_parameter_identifier" {
  description = "somleng"
}
