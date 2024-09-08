resource "aws_ssm_parameter" "somleng_regions_production" {
  name = "somleng.production.region_data"
  type = "String"
  value = jsonencode(
    [
      {
        alias      = "hydrogen",
        identifier = var.aws_default_region,
        human_name = "South East Asia (Singapore)",
        group_id   = 1,
        nat_ip     = module.hydrogen_region.vpc.nat_public_ips[0]
      },
      {
        alias      = "helium",
        identifier = var.aws_helium_region,
        human_name = "North America (North Virginia, USA)",
        group_id   = 2,
        nat_ip     = module.helium_region.vpc.nat_public_ips[0]
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
        alias      = "hydrogen",
        identifier = var.aws_default_region,
        human_name = "South East Asia (Singapore)",
        group_id   = 1,
        nat_ip     = module.hydrogen_region.vpc.nat_public_ips[0]
      },
      {
        alias      = "helium",
        identifier = var.aws_helium_region,
        human_name = "North America (North Virginia, USA)",
        group_id   = 2,
        nat_ip     = module.helium_region.vpc.nat_public_ips[0]
      }
    ]
  )
}
