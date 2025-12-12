module "db" {
  identifier          = "somleng"
  database_username   = "somleng"
  database_identifier = "somlengv2"
  source              = "../modules/db"
  region              = module.hydrogen_region
  engine_version      = "17.5"
}

module "db_staging" {
  identifier        = "somleng-staging"
  database_username = "somleng"
  source            = "../modules/db"
  region            = module.hydrogen_region
  min_capacity      = 0
  engine_version    = "17.6"
}
