data "terraform_remote_state" "test_vpc" {
  backend = "s3"

  config = {
    bucket = "terraform-production.bongloy.com"
    key    = "test-vpc.tfstate"
    region = var.aws_region
  }
}

provider "aws" {
  region  = var.aws_region
}
