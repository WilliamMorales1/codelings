#!/usr/bin/env bash
# REQUIRES: ip getent unshare
# HINT
# Just the address: `nameserver 10.53.0.53`. An unparseable nameserver line is
# skipped without a warning, and the resolver falls back to 127.0.0.1, where
# nothing listens.
source "$NETLINGS_ROOT/checks/lib.sh"
sandbox
topo_dns
sandbox_here "DNS server at 10.53.0.53 (zone lab.test). 'cp resolv.conf /etc/resolv.conf' applies your file;" \
  "queries it receives are logged in $DNS_LOG."

need_file resolv.conf
cp resolv.conf /etc/resolv.conf
expect_eq "$(resolves web.lab.test)" 10.53.0.80 "web.lab.test"
grep -q 'web.lab.test' "$DNS_LOG" || fail "the DNS server never saw a query"
ok "the query went to 10.53.0.53"
expect_eq "$(resolves www.lab.test)" 10.53.0.80 "www.lab.test (a CNAME to web)"
