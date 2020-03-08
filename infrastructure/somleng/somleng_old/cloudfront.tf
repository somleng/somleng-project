module "secure_headers" {
  source          = "../../modules/secure_headers"
  lambda_role_arn = "${aws_iam_role.secure_headers.arn}"

  providers = {
    aws = "aws.us-east-1"
  }
}

module "somleng_website" {
  source = "../../modules/cloudfront"

  domain_name             = "${aws_s3_bucket.website.website_endpoint}"
  aliases                 = ["www.somleng.org"]
  origin_protocol_policy  = "http-only"
  acm_certificate_arn     = "${aws_acm_certificate.cdn_certificate.arn}"
  lambda_qualified_arn    = "${module.secure_headers.lambda_qualified_arn}"
  logs_bucket_domain_name = "${aws_s3_bucket.logs.bucket_domain_name}"
}

module "somleng_naked_redirect" {
  source = "../../modules/cloudfront"

  domain_name             = "${aws_s3_bucket.somleng_org_redirection.website_endpoint}"
  aliases                 = ["somleng.org"]
  origin_protocol_policy  = "http-only"
  acm_certificate_arn     = "${aws_acm_certificate.root_cdn_certificate.arn}"
  lambda_qualified_arn    = "${module.secure_headers.lambda_qualified_arn}"
  logs_bucket_domain_name = "${aws_s3_bucket.logs.bucket_domain_name}"
}
