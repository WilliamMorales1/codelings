#!/usr/bin/env bash
# REQUIRES: tofu
# HINT
# Iterate with both key and value to get names:
#   public_services = [for name, s in var.services : name if s.public]
#   endpoints       = { for name, s in var.services : name => "${name}.internal:${s.port}" }
#   total_ports     = sum([for s in var.services : s.port])
source "$OPSLINGS_ROOT/checks/lib.sh"

need_file main.tf
tofu_test tofu2
