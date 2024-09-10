locals {
  nat_instance = var.create_nat_instance ? module.nat_instance[0] : null
}

module "nat_instance" {
  source               = "../nat_instance"
  count                = var.create_nat_instance ? 1 : 0
  vpc                  = module.vpc
  flow_logs_role       = var.flow_logs_role
  health_checker_image = var.nat_instance_health_checker_image
}
