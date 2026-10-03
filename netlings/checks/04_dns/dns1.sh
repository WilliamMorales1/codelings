#!/usr/bin/env bash
# REQUIRES: ip curl getent unshare
# HINT
# The address comes first, then the names: `10.0.0.2  api.internal api`.
# Any extra names on the same line are aliases.
source "$NETLINGS_ROOT/checks/lib.sh"
sandbox
ip link set lo up
newns b
ip link add host0 type veth peer name b0 netns b
ip link set host0 up
up b b0
ip addr add 10.0.0.1/24 dev host0
addr b b0 10.0.0.2/24
bg b "$(tmpfile)" netlings serve http -addr :80 -name api
wait_listen b 80
sandbox_here "b (10.0.0.2) runs a web server. 'cp hosts /etc/hosts' applies your file (only in here)."

need_file hosts
cp hosts /etc/hosts
expect_eq "$(resolves api.internal)" 10.0.0.2 "api.internal"
expect_eq "$(resolves api)" 10.0.0.2 "alias api"
expect_eq "$(resolves db.internal)" 10.0.0.3 "db.internal"
expect_match "$(resolves localhost)" "^(127.0.0.1|::1)$" "localhost still works"
expect_eq "$(curl -s --max-time 2 http://api.internal/)" "hello from api" "curl http://api.internal/"
