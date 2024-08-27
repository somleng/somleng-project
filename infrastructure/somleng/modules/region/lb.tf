locals {
  public_load_balancer_name                  = var.public_load_balancer_name == null ? var.vpc_name : var.public_load_balancer_name
  public_load_balancer_security_group_name   = var.public_load_balancer_security_group_name == null ? local.public_load_balancer_name : var.public_load_balancer_security_group_name
  internal_load_balancer_name                = var.internal_load_balancer_name == null ? var.vpc_name : var.internal_load_balancer_name
  internal_load_balancer_security_group_name = var.internal_load_balancer_security_group_name == null ? local.internal_load_balancer_name : var.internal_load_balancer_security_group_name
}

module "public_load_balancer" {
  source = "../load_balancer"

  count               = var.create_public_load_balancer ? 1 : 0
  name                = local.public_load_balancer_name
  security_group_name = local.public_load_balancer_security_group_name
  vpc                 = module.vpc
  ssl_certificate     = module.public_ssl_certificate[0].this
  logs_bucket         = aws_s3_bucket.logs
}

module "internal_load_balancer" {
  source = "../load_balancer"

  count               = var.create_internal_load_balancer ? 1 : 0
  name                = local.internal_load_balancer_name
  security_group_name = local.internal_load_balancer_security_group_name
  vpc                 = module.vpc
  internal            = true
  ssl_certificate     = module.internal_ssl_certificate[0].this
  logs_bucket         = aws_s3_bucket.logs
}
