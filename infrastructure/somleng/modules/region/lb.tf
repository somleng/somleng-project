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

# https://aws.amazon.com/blogs/networking-and-content-delivery/hosting-internal-https-static-websites-with-alb-s3-and-privatelink/
resource "aws_lb_target_group" "s3" {
  count       = var.create_s3_vpc_endpoint ? 1 : 0
  name        = "${local.internal_load_balancer_name}-s3"
  port        = 443
  protocol    = "HTTPS"
  vpc_id      = module.vpc.vpc_id
  target_type = "ip"

  health_check {
    protocol = "HTTP"
    path     = "/"
    port     = 80
    matcher  = "307,405"
  }
}

resource "aws_lb_target_group_attachment" "s3" {
  for_each = var.create_s3_vpc_endpoint ? {
    for subnet in module.vpc_endpoints.0.endpoints.s3.subnet_configuration :
    subnet.ipv4 => subnet
  } : {}
  target_group_arn = aws_lb_target_group.s3.0.arn
  target_id        = each.value.ipv4
  port             = 443
}
