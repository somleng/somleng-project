locals {
  start_index      = "${index(var.vpc_subnet_cidr_blocks, element(var.subnet_group_cidr_blocks, 0))}"
  end_index        = "${local.start_index + length(var.subnet_group_cidr_blocks)}"
  subnet_group_ids = "${slice(var.vpc_subnet_ids, local.start_index, local.end_index)}"
}
