variable "app_identifier" {}
variable "service_role_arn" {}

variable "appversion_lifecycle_max_count" {
  default = 50
}

variable "appversion_lifecycle_delete_source_from_s3" {
  default = true
}
