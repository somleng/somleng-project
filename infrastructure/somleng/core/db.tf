module "db" {
  source              = "../modules/db"
  identifier          = "somleng"
  database_username   = "somleng"
  database_identifier = "somlengv2"
  region              = module.hydrogen_region
  engine_version      = "17.5"
}

module "db_staging" {
  source            = "../modules/db"
  identifier        = "somleng-staging"
  database_username = "somleng"
  region            = module.hydrogen_region
  min_capacity      = 0
  engine_version    = "17.6"
}
