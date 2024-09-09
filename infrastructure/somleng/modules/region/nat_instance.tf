module "nat_instance" {
  source = "../nat_instance"
  count  = var.create_nat_instance ? 1 : 0
  vpc    = module.vpc
}
