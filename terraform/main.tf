locals {
  name_prefix = var.project_name
}

module "eventing" {
  source      = "./modules/eventing"
  name_prefix = local.name_prefix
  location    = var.location
  environment = var.environment
}
