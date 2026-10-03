#!/usr/bin/env bash
# REQUIRES: promtool
# HINT
#   - record: job:http_requests:rate5m
#     expr: sum by (job) (rate(http_requests_total[5m]))
source "$OPSLINGS_ROOT/checks/lib.sh"

need_file rules.yml
prom_check_rules rules.yml
prom_test prom2
