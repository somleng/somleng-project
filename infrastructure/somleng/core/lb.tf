module "public_load_balancer" {
  source = "../modules/load_balancer"

  name                = "somleng-application"
  security_group_name = "Somleng Application Load Balancer Security Group"
  vpc                 = module.vpc_hydrogen.vpc
  ssl_certificate     = module.public_ssl_certificate.this
  logs_bucket         = aws_s3_bucket.logs
}

module "internal_load_balancer" {
  source = "../modules/load_balancer"

  name                = "somleng-ialb"
  security_group_name = "Somleng Internal Application Load Balancer Security Group"
  vpc                 = module.vpc_hydrogen.vpc
  internal            = true
  ssl_certificate     = module.internal_ssl_certificate.this
  logs_bucket         = aws_s3_bucket.logs
}
