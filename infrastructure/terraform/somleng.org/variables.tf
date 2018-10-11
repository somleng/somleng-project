locals {
  terraform_bucket = "terraform.somleng.org"
}

variable "aws_region" {
  default = "ap-southeast-1"
}

variable "terraform_profile" {
  default = "somleng-terraform"
}
