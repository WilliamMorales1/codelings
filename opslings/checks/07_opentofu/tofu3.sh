#!/usr/bin/env bash
# REQUIRES: tofu
# HINT
#   condition = contains(["dev", "staging", "prod"], var.environment)
#
#   validation {
#     condition     = var.replicas >= 1 && var.replicas <= 10 && floor(var.replicas) == var.replicas
#     error_message = "replicas must be a whole number from 1 to 10."
#   }
#
#   condition = can(cidrhost(var.cidr, 0))
source "$OPSLINGS_ROOT/checks/lib.sh"

need_file main.tf
tofu_test tofu3
