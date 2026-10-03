#!/usr/bin/env bash
# REQUIRES: promtool
# HINT
# Two bugs: φ is a fraction (0.95, not 95), and the sum drops `le`:
#   histogram_quantile(0.95,
#     sum by (job, le) (rate(http_request_duration_seconds_bucket[5m])))
source "$OPSLINGS_ROOT/checks/lib.sh"

need_file rules.yml
prom_check_rules rules.yml
prom_test prom4
