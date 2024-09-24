resource "aws_ssm_parameter" "somleng_regions_production" {
  name = "somleng.production.region_data"
  type = "String"
  value = jsonencode(
    [
      {
        alias      = module.hydrogen_region.alias,
        identifier = module.hydrogen_region.aws_region,
        human_name = "South East Asia (Singapore)",
        group_id   = 1,
        nat_ip     = module.hydrogen_region.vpc.nat_public_ips[0],
        vpc_cidr   = module.hydrogen_region.vpc.vpc_cidr_block
      },
      {
        alias      = module.helium_region.alias,
        identifier = module.helium_region.aws_region,
        human_name = "North America (N. Virginia, USA)",
        group_id   = 2,
        nat_ip     = module.helium_region.vpc.nat_public_ips[0],
        vpc_cidr   = module.helium_region.vpc.vpc_cidr_block
      }
    ]
  )
}

resource "aws_ssm_parameter" "somleng_regions_staging" {
  name = "somleng.staging.region_data"
  type = "String"
  value = jsonencode(
    [
      {
        alias      = module.hydrogen_region.alias,
        identifier = module.hydrogen_region.aws_region,
        human_name = "South East Asia (Singapore)",
        group_id   = 1,
        nat_ip     = module.hydrogen_region.vpc.nat_public_ips[0],
        vpc_cidr   = module.hydrogen_region.vpc.vpc_cidr_block
      },
      {
        alias      = module.helium_region.alias,
        identifier = module.helium_region.aws_region,
        human_name = "North America (N. Virginia, USA)",
        group_id   = 2,
        nat_ip     = module.helium_region.vpc.nat_public_ips[0],
        vpc_cidr   = module.helium_region.vpc.vpc_cidr_block
      }
    ]
  )
}
