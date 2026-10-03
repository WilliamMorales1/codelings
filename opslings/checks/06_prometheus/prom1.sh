#!/usr/bin/env bash
# REQUIRES: promtool yq
# HINT
# `15` needs a unit: 15s. The key is `static_configs` (plural), and targets
# is a YAML list:
#   targets: ["localhost:9100", "10.0.0.2:9100"]
# Prometheus keys use underscores: metrics_path. A per-job
#   scrape_interval: 5s
# overrides the global one.
source "$OPSLINGS_ROOT/checks/lib.sh"

need_file prometheus.yml
out=$(promtool check config prometheus.yml 2>&1) || { echo "$out"; fail "promtool check config rejected prometheus.yml"; }
ok "promtool check config"
expect_yq prometheus.yml '.global.scrape_interval' "15s" "global scrape_interval"
expect_yq prometheus.yml '.global.evaluation_interval' "30s" "global evaluation_interval"
job() { yq eval ".scrape_configs[] | select(.job_name == \"$1\") | $2" prometheus.yml; }
expect_eq "$(job node '[.static_configs[].targets[]] | sort | join(",")')" "10.0.0.2:9100,localhost:9100" "node targets"
expect_eq "$(job api '[.static_configs[].targets[]] | join(",")')" "api.internal:8080" "api targets"
expect_eq "$(job api '.metrics_path')" "/internal/metrics" "api metrics_path"
expect_eq "$(job api '.scrape_interval')" "5s" "api scrape_interval"
