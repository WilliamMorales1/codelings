#!/usr/bin/env bash
# REQUIRES: tofu
# HINT
# Interpolate every reference, and always through `var.`:
#   value = "${var.app}-${var.env}"
#   value = "http://${var.app}.${var.env}.internal:${var.port}"
# and give port `type = number` with `default = 8080`.
source "$OPSLINGS_ROOT/checks/lib.sh"

need_file main.tf
grep -Pzo 'variable\s+"port"\s*\{[^}]*type\s*=\s*number' main.tf >/dev/null || fail 'variable "port" should have type = number'
ok "port is a number"
tofu_test tofu1
