resource "aws_vpc_peering_connection" "this" {
  vpc_id      = module.vpc.vpc_id
  peer_vpc_id = data.terraform_remote_state.core.outputs.vpc.vpc_id
  auto_accept = true

  tags = {
    Name = "Somleng-Old -> Somleng New"
  }
}

resource "aws_route" "vpc_to_peer_vpc" {
  for_each = toset(module.vpc.intra_route_table_ids)

  route_table_id            = each.value
  destination_cidr_block    = data.terraform_remote_state.core.outputs.vpc. vpc_cidr_block
  vpc_peering_connection_id = aws_vpc_peering_connection.this.id
}

resource "aws_route" "peer_vpc_to_vpc" {
  for_each = toset(data.terraform_remote_state.core.outputs.vpc.public_route_table_ids)

  route_table_id            = each.value
  destination_cidr_block    = module.vpc.vpc_cidr_block
  vpc_peering_connection_id = aws_vpc_peering_connection.this.id
}