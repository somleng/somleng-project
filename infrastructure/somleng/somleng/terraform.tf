terraform {
  backend "s3" {
    bucket  = "infrastructure.somleng.org"
    key     = "somleng.tfstate"
    encrypt = true
    region  = "ap-southeast-1"
  }

  required_version = ">= 0.12"
}

data "terraform_remote_state" "core" {
  backend = "s3"

  config = {
    bucket = "infrastructure.somleng.org"
    key    = "core.tfstate"
    region = var.aws_region
  }
}

provider "aws" {
  region = var.aws_region
}