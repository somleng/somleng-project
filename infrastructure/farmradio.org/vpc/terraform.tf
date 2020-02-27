terraform {
  backend "s3" {
    bucket  = "infrastructure.farmradio.org"
    key     = "somleng_vpc.tfstate"
    encrypt = true
    region  = "eu-west-1"
  }

  required_version = ">= 0.12"
}

provider "aws" {
  region = var.aws_region
}