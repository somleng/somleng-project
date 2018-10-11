module "twilreapi_eb_solution_stack" {
  source             = "../modules/eb_solution_stacks"
  major_ruby_version = "${local.twilreapi_major_ruby_version}"
}
