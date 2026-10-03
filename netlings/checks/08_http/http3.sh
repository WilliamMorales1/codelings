#!/usr/bin/env bash
# REQUIRES: ip curl unshare
# HINT
# curl cannot resolve shop.lab.test (exit code 6, "Could not resolve host").
# Tell it the address yourself: --resolve shop.lab.test:80:10.0.0.2 . Note
# the port in the middle: the override only applies to that name AND port.
source "$NETLINGS_ROOT/checks/lib.sh"
sandbox
topo_web
cp /etc/hosts /run/netlings/hosts.orig
sandbox_here "b (10.0.0.2) serves shop.lab.test and blog.lab.test; no DNS. Try 'ip netns exec a bash fetch.sh'."

capture fetch.sh a
cmp -s /etc/hosts /run/netlings/hosts.orig || fail "fetch.sh changed /etc/hosts"
expect_eq "$OUT" "welcome to the shop" "fetch.sh printed the shop's page"
