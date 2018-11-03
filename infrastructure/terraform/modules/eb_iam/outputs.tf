output "eb_service_role" {
  value = "${aws_iam_instance_profile.eb_service.name}"
}

output "eb_ec2_instance_role" {
  value = "${aws_iam_instance_profile.eb_ec2.name}"
}

output "eb_service_role_arn" {
  value = "${aws_iam_role.eb_service_role.arn}"
}
