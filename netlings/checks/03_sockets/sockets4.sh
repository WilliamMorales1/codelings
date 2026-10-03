#!/usr/bin/env bash
# REQUIRES: ip unshare
# HINT
# Read exactly one line: `read -r reply <&3` then `echo "$reply"`. (Or
# `head -n1 <&3`.) Close with `exec 3>&-` if you like; the script ending does
# that too.
source "$NETLINGS_ROOT/checks/lib.sh"
sandbox
topo_pair
bg b "$(tmpfile)" netlings serve echo -addr :7
wait_listen b 7
sandbox_here "a (10.0.0.1) <-> b (10.0.0.2, echo server on port 7). Try 'ip netns exec a bash client.sh'."

capture client.sh a
expect_eq "$OUT" "hello netlings" "client.sh printed the echoed line"
