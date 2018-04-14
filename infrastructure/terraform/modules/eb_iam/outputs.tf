output "eb_service_role" {
  value = "${data.aws_iam_role.eb_service_role.name}"
}

output "eb_ec2_instance_role" {
  value = "${data.aws_iam_role.eb_ec2_instance_role.name}"
}
