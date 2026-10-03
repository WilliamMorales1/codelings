#!/usr/bin/env bash
# REQUIRES: ip tc ping unshare
# HINT
# With -F/ the rtt line splits into: "rtt min", "avg", "max", "mdev = 41.183",
# "43.702", "47.020", "1.936 ms". The avg value is field 5; printf "%d" drops
# the decimals. For the loss, grep -oE '[0-9.]+% packet loss' then strip the
# "% packet loss" part.
source "$NETLINGS_ROOT/checks/lib.sh"
sandbox
topo_pair
delay=$((30 + RANDOM % 40))
ns a tc qdisc add dev a0 root netem delay "${delay}ms" 2ms
sandbox_here "a <-> b with ${delay}ms delay on a0. Try 'ip netns exec a bash measure.sh'."

capture measure.sh a
mapfile -t lines <<<"$OUT"
expect_eq "${#lines[@]}" 2 "two lines of output"
[[ ${lines[0]} =~ ^[0-9]+$ ]] || fail "line 1 should be a whole number of ms, got '${lines[0]}'"
((lines[0] >= delay - 3 && lines[0] <= delay + 10)) || fail "line 1: average RTT ${lines[0]}ms, but the link has ${delay}ms of delay"
ok "average RTT ${lines[0]}ms (link delay ${delay}ms)"
expect_eq "${lines[1]}" 0 "line 2: packet loss percent"
