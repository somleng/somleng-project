resource "aws_globalaccelerator_accelerator" "somleng" {
  name            = "somleng"
  ip_address_type = "IPV4"
  enabled         = true
}
