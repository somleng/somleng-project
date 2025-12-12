

data "aws_region" "accepter" {
  provider = aws.accepter
}

resource "aws_vpc_peering_connection" "requester" {
  vpc_id      = var.requester_region.vpc.vpc_id
  peer_vpc_id = var.accepter_region.vpc.vpc_id
  peer_region = data.aws_region.accepter.region

  tags = {
    Name = "${var.requester_region.alias} <-> ${var.accepter_region.alias}"
  }
}

resource "aws_vpc_peering_connection_options" "requester" {
  vpc_peering_connection_id = aws_vpc_peering_connection.requester.id

  requester {
    allow_remote_vpc_dns_resolution = true
  }
}

resource "aws_route" "requester" {
  for_each                  = toset(concat(var.requester_region.vpc.public_route_table_ids, var.requester_region.vpc.private_route_table_ids, var.requester_region.vpc.intra_route_table_ids))
  route_table_id            = each.value
  destination_cidr_block    = var.accepter_region.vpc.vpc_cidr_block
  vpc_peering_connection_id = aws_vpc_peering_connection.requester.id
}

resource "aws_vpc_peering_connection_accepter" "accepter" {
  vpc_peering_connection_id = aws_vpc_peering_connection.requester.id

  auto_accept = true
  tags = {
    Name = "${var.accepter_region.alias} <-> ${var.requester_region.alias}"
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
  for_each                  = toset(concat(var.accepter_region.vpc.public_route_table_ids, var.accepter_region.vpc.private_route_table_ids, var.accepter_region.vpc.intra_route_table_ids))
  route_table_id            = each.value
  destination_cidr_block    = var.requester_region.vpc.vpc_cidr_block
  vpc_peering_connection_id = aws_vpc_peering_connection_accepter.accepter.id

  provider = aws.accepter
}
