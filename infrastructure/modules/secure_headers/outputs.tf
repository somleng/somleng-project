output "lambda_qualified_arn" {
  value = "${aws_lambda_function.this.qualified_arn}"
}

