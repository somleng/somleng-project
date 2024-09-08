

data "aws_region" "accepter" {
  provider = aws.accepter
}

resource "aws_vpc_peering_connection" "requester" {
  vpc_id      = var.requester_vpc.vpc_id
  peer_vpc_id = var.accepter_vpc.vpc_id
  peer_region = data.aws_region.accepter.name

  tags = {
    Name = "${var.requester_alias} <-> ${var.accepter_alias}"
  }
}

resource "aws_vpc_peering_connection_options" "requester" {
  vpc_peering_connection_id = aws_vpc_peering_connection.requester.id

  requester {
    allow_remote_vpc_dns_resolution = true
  }
}

resource "aws_route" "requester" {
  for_each                  = toset(var.requester_vpc.private_route_table_ids)
  route_table_id            = each.value
  destination_cidr_block    = var.accepter_vpc.vpc_cidr_block
  vpc_peering_connection_id = aws_vpc_peering_connection.requester.id
}

resource "aws_vpc_peering_connection_accepter" "accepter" {
  vpc_peering_connection_id = aws_vpc_peering_connection.requester.id

  auto_accept = true
  tags = {
    Name = "${var.accepter_alias} <-> ${var.requester_alias}"
  }
  provider = aws.accepter
}

resource "aws_vpc_peering_connection_options" "accepter" {
  vpc_peering_connection_id = aws_vpc_peering_connection_accepter.accepter.id

  accepter {
    allow_remote_vpc_dns_resolution = true
  }

  provider = aws.accepter
}

resource "aws_route" "accepter" {
  for_each                  = toset(var.accepter_vpc.private_route_table_ids)
  route_table_id            = each.value
  destination_cidr_block    = var.requester_vpc.vpc_cidr_block
  vpc_peering_connection_id = aws_vpc_peering_connection_accepter.accepter.id

  provider = aws.accepter
}
