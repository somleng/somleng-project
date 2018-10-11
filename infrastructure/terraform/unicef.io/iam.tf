module "terraform_iam" {
  source = "../modules/terraform_iam"
}

module "eb_iam" {
  source = "../modules/eb_iam"
}

module "s3_iam" {
  source = "../modules/s3_iam"
}

module "ci_iam" {
  source = "../modules/ci_iam"
}
