terraform {
  backend "s3" {
    bucket  = "infrastructure.aws-activate-1.somleng.org"
    key     = "bootstrap.tfstate"
    encrypt = true
    region  = "ap-southeast-1"
  }

  required_version = ">= 0.12"
}

provider "aws" {
  region = var.aws_region
}
