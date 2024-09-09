# Routes that need to use the NAT Instance

resource "aws_route" "zamtel" {
  route_table_id         = var.vpc.private_route_table_ids[0]
  destination_cidr_block = "165.57.32.1/32"
  network_interface_id   = aws_network_interface.this.id
}

resource "aws_route" "zamtel_media" {
  route_table_id         = var.vpc.private_route_table_ids[0]
  destination_cidr_block = "165.57.33.2/32"
  network_interface_id   = aws_network_interface.this.id
}

resource "aws_route" "telecom_cambodia_signaling" {
  route_table_id         = var.vpc.private_route_table_ids[0]
  destination_cidr_block = "203.223.42.142/32"
  network_interface_id   = aws_network_interface.this.id
}

resource "aws_route" "telecom_cambodia_media" {
  route_table_id         = var.vpc.private_route_table_ids[0]
  destination_cidr_block = "203.223.42.132/32"
  network_interface_id   = aws_network_interface.this.id
}

resource "aws_route" "telecom_cambodia_media2" {
  route_table_id         = var.vpc.private_route_table_ids[0]
  destination_cidr_block = "203.223.42.148/32"
  network_interface_id   = aws_network_interface.this.id
}

# Health checker routes
# dig +short api.ipify.org
# 172.67.74.152
# 104.26.13.205
# 104.26.12.205

resource "aws_route" "health_check_target" {
  for_each               = toset(["172.67.74.152", "104.26.13.205", "104.26.12.205"])
  route_table_id         = var.vpc.private_route_table_ids[0]
  destination_cidr_block = "${each.key}/32"
  network_interface_id   = aws_network_interface.this.id
}
