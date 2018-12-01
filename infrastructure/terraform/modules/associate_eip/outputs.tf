output "event_detail_type" {
  value = "${local.event_detail_type}"
}

output "lambda_arn" {
  value = "${aws_lambda_function.associate_eip.arn}"
}
