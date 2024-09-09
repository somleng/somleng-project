terraform {
  backend "s3" {
    bucket  = "infrastructure.somleng.org"
    key     = "core.tfstate"
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

provider "aws" {
  region = var.aws_helium_region
  alias  = "helium"
}

data "aws_ecr_authorization_token" "this" {}

provider "docker" {
  registry_auth {
    address  = data.aws_ecr_authorization_token.this.proxy_endpoint
    username = data.aws_ecr_authorization_token.this.user_name
    password = data.aws_ecr_authorization_token.this.password
  }
}
