resource "aws_globalaccelerator_accelerator" "somleng" {
  name            = "somleng"
  ip_address_type = "IPV4"

  attributes {
    flow_logs_enabled   = true
    flow_logs_s3_bucket = module.hydrogen_region.logs_bucket.id
    flow_logs_s3_prefix = "ga-flow-logs/"
  }
}

resource "aws_globalaccelerator_listener" "somleng" {
  accelerator_arn = aws_globalaccelerator_accelerator.somleng.id
  protocol        = "TCP"

  port_range {
    from_port = 80
    to_port   = 80
  }

  port_range {
    from_port = 443
    to_port   = 443
  }
}

resource "aws_globalaccelerator_endpoint_group" "somleng" {
  listener_arn = aws_globalaccelerator_listener.somleng.id

  endpoint_configuration {
    endpoint_id                    = module.hydrogen_region.public_load_balancer.this.arn
    client_ip_preservation_enabled = true
  }
}
