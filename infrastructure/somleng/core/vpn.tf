resource "aws_customer_gateway" "lao_telecom" {
  bgp_asn    = 65000
  ip_address = "115.84.121.251"
  type       = "ipsec.1"

  tags = {
    "Name" = "lao telecom"
  }

}

resource "aws_vpn_gateway" "this" {
  vpc_id = module.hydrogen_region.vpc.vpc_id
}

resource "aws_vpn_connection" "lao_telecom" {
  customer_gateway_id = aws_customer_gateway.lao_telecom.id
  vpn_gateway_id      = aws_vpn_gateway.this.id
  type                = aws_customer_gateway.lao_telecom.type

  tags = {
    "Name" = "lao telecom"
  }
}

resource "aws_vpn_connection_route" "lao_telecom_smpp" {
  destination_cidr_block = "115.84.121.194/32"
  vpn_connection_id      = aws_vpn_connection.lao_telecom.id
}

resource "aws_vpn_gateway_route_propagation" "lao_telecom" {
  vpn_gateway_id = aws_vpn_gateway.this.id
  route_table_id = module.hydrogen_region.vpc.public_route_table_ids[0]
}
