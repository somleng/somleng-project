provider "archive" {
}

locals {
  lambda_runtime         = "nodejs8.10"
  lambda_function_name   = "secure_headers"
  lambda_handler         = "${local.lambda_function_name}.lambda_handler"
  path_to_lambda_source  = "${path.module}/lambda/secure_headers.js"
  path_to_lambda_archive = "${path.module}/lambda/secure_headers.zip"
}

resource "aws_lambda_function" "this" {
  filename         = "${local.path_to_lambda_archive}"
  function_name    = "${local.lambda_function_name}"
  runtime          = "${local.lambda_runtime}"
  handler          = "${local.lambda_handler}"
  role             = "${var.lambda_role_arn}"
  source_code_hash = "${data.archive_file.this.output_base64sha256}"
  publish          = true
}

data "archive_file" "this" {
  type        = "zip"
  source_file = "${local.path_to_lambda_source}"
  output_path = "${local.path_to_lambda_archive}"
}

