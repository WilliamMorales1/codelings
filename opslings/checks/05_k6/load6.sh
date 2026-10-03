#!/usr/bin/env bash
# REQUIRES: k6 jq curl
# HINT
# The executor is called 'constant-vus' (plural), and without `exec` a
# scenario runs the default export, which this script does not have:
#   browse:   { executor: 'constant-vus', vus: 3, duration: '3s', exec: 'browse' },
#   checkout: { executor: 'shared-iterations', vus: 2, iterations: 10, exec: 'checkout' },
source "$OPSLINGS_ROOT/checks/lib.sh"

need_file script.js
expect_eq "$(k6_opt '.scenarios.browse | [.executor, .vus, .duration, .exec]')" '["constant-vus",3,"3s","browse"]' "browse scenario"
expect_eq "$(k6_opt '.scenarios.checkout | [.executor, .vus, .iterations, .exec]')" '["shared-iterations",2,10,"checkout"]' "checkout scenario"
start_target
k6_ok script.js
expect_eq "$(stat_count 'GET /api/items/{id} 200')" "10" "checkout ran exactly 10 iterations"
n=$(stat_count 'GET /api/items 200')
((n >= 9)) || fail "browse made only $n requests (3 VUs, 3s, 0.5s sleep: expected ~18)"
ok "browse made $n requests"
