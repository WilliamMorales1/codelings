#!/usr/bin/env bash
# REQUIRES: ss ip unshare
# HINT
# Nothing listens on TCP 5140, hence "Connection refused". The collector is
# UDP: `ip netns exec b ss -uln` shows it. bash spells that /dev/udp/HOST/PORT.
source "$NETLINGS_ROOT/checks/lib.sh"
sandbox
topo_pair
got=$(tmpfile)
bg b "$(tmpfile)" netlings serve udp -addr :5140 -out "$got"
wait_listen b 5140
sandbox_here "a (10.0.0.1) <-> b (10.0.0.2, UDP collector on 5140, writing to $got)." \
  "Try 'ip netns exec a bash send.sh; cat $got'."

capture send.sh a
sleep 0.2
expect_eq "$(cat "$got")" "<14>netlings: link up" "the collector received exactly the message"
