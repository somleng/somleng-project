variable "domain_name" {
}

variable "aliases" {
  type = "list"
}

variable "acm_certificate_arn" {
}

variable "origin_protocol_policy" {
}

variable "lambda_qualified_arn" {
}

variable "logs_bucket_domain_name" {
}

variable "origin_ssl_protocols" {
  type    = "list"
  default = ["TLSv1.2"]
}

variable "viewer_protocol_policy" {
  default = "redirect-to-https"
}

