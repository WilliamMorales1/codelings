#!/usr/bin/env bash
# REQUIRES: promtool
# HINT
# PromQL compares with `==`; a single `=` only appears inside {label="x"}:
#   expr: up == 0
# absent() already returns 1 exactly when the series is missing, so use it
# as is:
#   expr: absent(up{job="api"})
source "$OPSLINGS_ROOT/checks/lib.sh"

need_file rules.yml
prom_check_rules rules.yml
prom_test prom5
