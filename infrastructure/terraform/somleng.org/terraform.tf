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
    bucket  = "terraform.somleng.org" # cannot interpolate here
    key     = "terraform.tfstate"
    encrypt = true
  }
}

module "terraform" {
  source                     = "../modules/terraform"
  bastion_host_subnet_id     = "${element(module.vpc.private_subnets, 0)}"
  infrastructure_source_repo = "https://github.com/somleng/somleng-project"
}
