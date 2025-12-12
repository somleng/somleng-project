variable "aws_default_region" {
  default = "ap-southeast-1"
}
variable "create_db" {
  description = "y or n"
}
variable "restore_db" {
  description = "y or n (BE CAREFUL! THIS WILL DROP THE DATABASE IF IN DOUBT SELECT 'n')"
}
variable "restore_db_from_backup_name" {
  description = "somleng, somleng_staging"
}
variable "db_name" {
  description = "somleng, somleng_staging"
}
variable "cluster_identifier" {
  description = "somlengv2, somleng-staging"
}
variable "db_master_password_parameter_identifier" {
  description = "somleng, somleng-staging"
}
