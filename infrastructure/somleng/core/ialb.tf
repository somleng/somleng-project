resource "aws_security_group" "somleng_internal_application_load_balancer" {
  name   = "Somleng Internal Application Load Balancer Security Group"
  vpc_id = module.vpc_hydrogen.vpc.vpc_id
}

resource "aws_security_group_rule" "internal_https_ingress" {
  type        = "ingress"
  from_port   = 443
  to_port     = 443
  protocol    = "tcp"
  cidr_blocks = [module.vpc_hydrogen.vpc.vpc_cidr_block]

  security_group_id = aws_security_group.somleng_internal_application_load_balancer.id
}

resource "aws_security_group_rule" "internal_http_ingress" {
  type        = "ingress"
  from_port   = 80
  to_port     = 80
  protocol    = "tcp"
  cidr_blocks = [module.vpc_hydrogen.vpc.vpc_cidr_block]

  security_group_id = aws_security_group.somleng_internal_application_load_balancer.id
}

resource "aws_security_group_rule" "internal_egress" {
  type        = "egress"
  from_port   = 0
  to_port     = 65535
  protocol    = "tcp"
  cidr_blocks = [module.vpc_hydrogen.vpc.vpc_cidr_block]

  security_group_id = aws_security_group.somleng_internal_application_load_balancer.id
}

resource "aws_lb" "somleng_internal_application" {
  name                             = "somleng-ialb"
  load_balancer_type               = "application"
  internal                         = true
  subnets                          = module.vpc_hydrogen.vpc.intra_subnets
  security_groups                  = [aws_security_group.somleng_internal_application_load_balancer.id]
  enable_cross_zone_load_balancing = true

  access_logs {
    bucket  = aws_s3_bucket.logs.id
    prefix  = "somleng-ialb"
    enabled = true
  }
}

resource "aws_lb_listener" "internal_https" {
  load_balancer_arn = aws_lb.somleng_internal_application.arn
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-TLS13-1-2-2021-06"
  certificate_arn   = aws_acm_certificate.internal_certificate.arn

  default_action {
    type = "fixed-response"

    fixed_response {
      content_type = "text/plain"
      message_body = "Not Found"
      status_code  = "404"
    }
  }
}

resource "aws_lb_listener" "internal_http" {
  load_balancer_arn = aws_lb.somleng_internal_application.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type = "redirect"

    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}
