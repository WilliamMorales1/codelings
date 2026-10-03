#!/usr/bin/env bash
# REQUIRES: tofu
# HINT
# source = "./modules/service", and pass `port`, the variable the module
# actually declares. In modules/service/main.tf:
#   output "address" {
#     value = "${var.name}.${var.namespace}.svc.cluster.local:${var.port}"
#   }
# Then:
#   module "web" { source = "./modules/service"  name = "web"  port = 80  namespace = "shop" }
#   output "web_address" { value = module.web.address }
source "$OPSLINGS_ROOT/checks/lib.sh"

need_file main.tf modules/service/main.tf
tofu_test tofu5
