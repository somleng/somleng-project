terraform {
  backend "s3" {
    bucket  = "infrastructure.farmradio.org"
    key     = "somleng.tfstate"
    encrypt = true
    region  = "eu-west-1"
  }

  required_version = ">= 0.12"
}

data "terraform_remote_state" "core" {
  backend = "s3"

  config = {
    bucket = "infrastructure.farmradio.org"
    key    = "route53.tfstate"
    region = var.aws_region
  }
}

provider "aws" {
  region = var.aws_region
}