#!/usr/bin/env bash
# REQUIRES: k6 jq curl
# HINT
# A stage has `duration` and `target` (not vus), and you need a third one
# to ramp down:
#   { duration: '1s', target: 5 },
#   { duration: '2s', target: 5 },
#   { duration: '1s', target: 0 },
# Threshold values are plain milliseconds with a p(N) aggregation:
#   http_req_duration: ['p(95)<300'],
source "$OPSLINGS_ROOT/checks/lib.sh"

need_file script.js
expect_eq "$(k6_opt '.stages')" '[{"duration":"1s","target":5},{"duration":"2s","target":5},{"duration":"1s","target":0}]' "stages"
expect_match "$(k6_opt '.thresholds.http_req_duration[]' | tr -d ' ')" '^"p\(95\)<300"$' "p(95) threshold"
start_target
k6_ok script.js
n=$(stat_count 'GET /slow 200')
((n > 10)) || fail "only $n requests: did the VUs ramp up?"
ok "$n requests while ramping"
reset_target
k6_run -e SLOW_MS=400 script.js
expect_eq "$K6_RC" "99" "k6 exit code with SLOW_MS=400 (threshold crossed)"
