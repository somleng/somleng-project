locals {
  terraform_bucket = "terraform.ews1294.info"
  vpc_name = "pin-production"
}

variable "aws_region" {
  default = "ap-southeast-1"
}

variable "terraform_profile" {
  default = "ews1294-terraform"
}
