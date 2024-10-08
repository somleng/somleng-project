terraform {
  backend "s3" {
    bucket  = "infrastructure.somleng.org"
    key     = "somleng_switch_testing.tfstate"
    encrypt = true
    region  = "ap-southeast-1"
  }
}

provider "aws" {
  region = local.region.aws_region
}

data "terraform_remote_state" "core_infrastructure" {
  backend = "s3"

  config = {
    bucket = "infrastructure.somleng.org"
    key    = "core.tfstate"
    region = "ap-southeast-1"
  }
}
