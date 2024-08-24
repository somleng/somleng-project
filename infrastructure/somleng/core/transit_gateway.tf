# resource "aws_ec2_transit_gateway" "hydrogen" {
#   description = "Somleng"

#   tags = {
#     Name = "Somleng"
#   }

#   amazon_side_asn = 64512
# }

# resource "aws_ec2_transit_gateway" "helium" {
#   description = "Helium"

#   tags = {
#     Name = "Helium"
#   }

#   amazon_side_asn = 64513

#   provider = aws.helium
# }

# resource "aws_ec2_transit_gateway_peering_attachment" "hydrogen_helium" {
#   peer_account_id         = aws_ec2_transit_gateway.helium.owner_id
#   peer_region             = data.aws_region.helium.name
#   peer_transit_gateway_id = aws_ec2_transit_gateway.helium.id
#   transit_gateway_id      = aws_ec2_transit_gateway.hydrogen.id

#   tags = {
#     Name = "Hydrogen - Helium"
#   }
# }

# resource "aws_ec2_transit_gateway_peering_attachment_accepter" "helium_hydrogen" {
#   transit_gateway_attachment_id = aws_ec2_transit_gateway_peering_attachment.hydrogen_helium.id

#   tags = {
#     Name = "Helium - Hydrogen"
#   }

#   provider = aws.helium
# }

# resource "aws_ec2_transit_gateway_vpc_attachment" "vpc_hydrogen" {
#   subnet_ids         = module.vpc_hydrogen.vpc.private_subnets
#   transit_gateway_id = aws_ec2_transit_gateway.hydrogen.id
#   vpc_id             = module.vpc_hydrogen.vpc.vpc_id

#   tags = {
#     Name = "Hydrogen"
#   }
# }

# resource "aws_ec2_transit_gateway_route" "hydrogen_helium" {
#   destination_cidr_block         = module.vpc_helium.vpc_cidr_block
#   transit_gateway_attachment_id  = aws_ec2_transit_gateway_peering_attachment.hydrogen_helium.id
#   transit_gateway_route_table_id = aws_ec2_transit_gateway.hydrogen.association_default_route_table_id
# }

# resource "aws_ec2_transit_gateway_vpc_attachment" "vpc_helium" {
#   subnet_ids         = module.vpc_helium.private_subnets
#   transit_gateway_id = aws_ec2_transit_gateway.helium.id
#   vpc_id             = module.vpc_helium.vpc_id

#   tags = {
#     Name = "Helium"
#   }

#   provider = aws.helium
# }

# resource "aws_ec2_transit_gateway_route" "helium_hydrogen" {
#   destination_cidr_block         = module.vpc_hydrogen.vpc.vpc_cidr_block
#   transit_gateway_attachment_id  = aws_ec2_transit_gateway_peering_attachment_accepter.helium_hydrogen.id
#   transit_gateway_route_table_id = aws_ec2_transit_gateway.helium.association_default_route_table_id

#   provider = aws.helium
# }

# resource "aws_route" "hydrogen_private_tg_test" {
#   route_table_id         = module.vpc_hydrogen.vpc.private_route_table_ids[0]
#   destination_cidr_block = "159.89.140.122/32"
#   transit_gateway_id     = aws_ec2_transit_gateway.hydrogen.id
# }

# resource "aws_ec2_transit_gateway_route" "hydrogen_helium_peer_test" {
#   destination_cidr_block         = "0.0.0.0/0"
#   transit_gateway_attachment_id  = aws_ec2_transit_gateway_peering_attachment.hydrogen_helium.id
#   transit_gateway_route_table_id = aws_ec2_transit_gateway.hydrogen.association_default_route_table_id
# }

# resource "aws_ec2_transit_gateway_route" "helium_to_vpc_test" {
#   destination_cidr_block         = "0.0.0.0/32"
#   transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.vpc_helium.id
#   transit_gateway_route_table_id = aws_ec2_transit_gateway.helium.association_default_route_table_id
#   provider                       = aws.helium
# }

# resource "aws_route" "helium_hydrogen_public" {
#   route_table_id         = module.vpc_helium.public_route_table_ids[0]
#   destination_cidr_block = module.vpc_hydrogen.vpc.vpc_cidr_block
#   transit_gateway_id     = aws_ec2_transit_gateway.helium.id

#   provider = aws.helium
# }

# resource "aws_route" "helium_hydrogen_private" {
#   route_table_id         = module.vpc_helium.private_route_table_ids[0]
#   destination_cidr_block = module.vpc_hydrogen.vpc.vpc_cidr_block
#   transit_gateway_id     = aws_ec2_transit_gateway.helium.id

#   provider = aws.helium
# }
