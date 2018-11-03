resource "aws_elastic_beanstalk_application" "app" {
  name = "${var.app_identifier}"

  appversion_lifecycle {
    service_role          = "${var.service_role_arn}"
    max_count             = "${var.appversion_lifecycle_max_count}"
    delete_source_from_s3 = "${var.appversion_lifecycle_delete_source_from_s3}"
  }
}
