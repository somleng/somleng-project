terraform {
  backend "s3" {
    bucket  = "infrastructure.somleng.org"
    key     = "somleng.com.tfstate"
    encrypt = true
    region  = "ap-southeast-1"
  }

  required_version = ">= 0.12"
}

provider "aws" {
  region = var.aws_default_region
}

provider "aws" {
  region = "us-east-1"
  alias  = "us-east-1"
}
