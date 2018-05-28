module "terraform_s3_bucket" {
  source = "../modules/terraform_s3_bucket"
  bucket = "${local.terraform_bucket}"
}

provider "aws" {
  profile = "${var.terraform_profile}"
  region  = "${var.aws_region}"
}

provider "aws" {
  profile = "${var.terraform_profile}"
  region  = "us-east-1"
  alias   = "us-east-1"
}

terraform {
  backend "s3" {
    bucket  = "terraform.ews1294.info" # cannot interpolate here
    key     = "terraform.tfstate"
    encrypt = true
  }
}
