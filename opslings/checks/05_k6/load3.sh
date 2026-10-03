#!/usr/bin/env bash
# REQUIRES: k6 jq curl
# HINT
# The built-in metric is http_req_failed (not http_req_fail):
#   thresholds: {
#     http_req_failed: ['rate<0.01'],
#     http_req_duration: ['p(95)<200'],
#     checks: ['rate>0.99'],
#   },
# and in the default function:
#   check(res, { 'status is 200': (r) => r.status === 200 });
source "$OPSLINGS_ROOT/checks/lib.sh"

need_file script.js
expect_eq "$(k6_opt '.thresholds.http_req_failed')" '["rate<0.01"]' "threshold on http_req_failed"
expect_eq "$(k6_opt '.thresholds.http_req_duration')" '["p(95)<200"]' "threshold on http_req_duration"
expect_match "$(k6_opt '.thresholds.checks')" 'rate>0\.99' "threshold on checks"
start_target
sum=$(mktemp "${TMPDIR:-/tmp}/opslings-k6-XXXXXX.json")
_cleanup_dirs+=("$sum")
k6_ok --summary-export "$sum" script.js
passes=$(jq '.metrics.checks.passes // 0' "$sum")
((passes > 0)) || fail "no checks ran: call check(res, {...}) in the default function"
ok "$passes checks passed on /api/items"
reset_target
k6_run --summary-export "$sum" -e TARGET_PATH=/flaky script.js
expect_eq "$K6_RC" "99" "k6 exit code on /flaky (thresholds crossed)"
fails=$(jq '.metrics.checks.fails // 0' "$sum")
((fails > 0)) || fail "the status check never failed on /flaky, where every 3rd request is a 500"
ok "$fails checks failed on /flaky"
