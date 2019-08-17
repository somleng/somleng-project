output "event_detail_type" {
  value = "${local.event_detail_type}"
}

output "lambda_arn" {
  value = "${aws_lambda_function.associate_eip.arn}"
}

output "eip_allocation_id_tag_key" {
  value = "${local.eip_allocation_id_tag_key}"
}
