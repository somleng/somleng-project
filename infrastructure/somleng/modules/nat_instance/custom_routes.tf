# Routes that need to use the NAT Instance

resource "aws_route" "custom" {
  for_each               = var.custom_routes
  route_table_id         = var.vpc.private_route_table_ids[0]
  destination_cidr_block = each.value
  network_interface_id   = aws_network_interface.this.id
}

# Health checker routes
# dig +short api.ipify.org
# 172.67.74.152
# 104.26.13.205
# 104.26.12.205

resource "aws_route" "health_check_target" {
  for_each               = toset(["172.67.74.152/32", "104.26.13.205/32", "104.26.12.205/32"])
  route_table_id         = var.vpc.private_route_table_ids[0]
  destination_cidr_block = each.key
  network_interface_id   = aws_network_interface.this.id
}
