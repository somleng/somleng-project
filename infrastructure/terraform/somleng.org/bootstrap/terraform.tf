terraform {
  # backend "local" {}
  backend "s3" {
    bucket  = "infrastructure.somleng.org"
    key     = "bootstrap.tfstate"
    encrypt = true
    region  = "ap-southeast-1"
  }
}

provider "aws" {
  region = var.aws_region
}

