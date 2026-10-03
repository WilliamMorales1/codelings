# tofu5 -- local modules
#
# Any directory of .tf files is a module. You call one with a `module`
# block; its variables become the block's arguments, and its outputs are
# read as module.<name>.<output>. Only outputs cross the module boundary.
#
# A *local* module source must start with ./ or ../ -- anything else is
# taken to be a registry address like "hashicorp/consul/aws".
#
#   tofu init                  # also installs modules
#   tofu plan
#
# Task:
#   - modules/service exposes output `address`:
#     "<name>.<namespace>.svc.cluster.local:<port>"
#   - call it twice: module "api" (name api, port 8080, namespace shop) and
#     module "web" (name web, port 80, namespace shop)
#   - root outputs api_address and web_address from the modules
#

module "api" {
  source = "modules/service"

  name         = "api"
  service_port = 8080
  namespace    = "shop"
}

# TODO: module "web"

output "api_address" {
  value = module.api.address
}

output "web_address" {
  value = "TODO"
}
