locals {
  terraform_bucket = "terraform.unicef.io"
}

variable "aws_region" {
  default = "ap-southeast-1"
}

variable "terraform_profile" {
  default = "unicef-terraform"
}
