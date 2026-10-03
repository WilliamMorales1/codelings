#!/usr/bin/env bash
# REQUIRES: promtool
# HINT
# `code="5xx"` matches only a label whose value is literally 5xx. Use a regex:
#   http_requests_total{code=~"5.."}
# Add `for: 10m` next to expr, and set `severity: page`.
source "$OPSLINGS_ROOT/checks/lib.sh"

need_file rules.yml
prom_check_rules rules.yml
prom_test prom3
