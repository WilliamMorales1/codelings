#!/usr/bin/env bash
# REQUIRES: ip dig unshare
# HINT
# Name the record type: `dig +short lab.test MX`, `dig +short _verify.lab.test TXT`.
# Reverse lookups use -x: `dig +short -x 10.53.0.80`. For the TTL, print only
# the answer section and take the second column:
#   dig +noall +answer api.lab.test | awk '{print $2}'
source "$NETLINGS_ROOT/checks/lib.sh"
sandbox
topo_dns
echo "nameserver 10.53.0.53" >/etc/resolv.conf
sandbox_here "/etc/resolv.conf points at 10.53.0.53. Try 'dig lab.test MX', then 'bash lookup.sh'."

capture lookup.sh
mapfile -t lines <<<"$OUT"
expect_eq "${lines[0]:-}" "10 mail.lab.test." "line 1: MX of lab.test"
expect_eq "${lines[1]:-}" '"netlings-verification=7f3a9c"' "line 2: TXT of _verify.lab.test"
expect_eq "${lines[2]:-}" "web.lab.test." "line 3: PTR for 10.53.0.80"
expect_eq "${lines[3]:-}" "60" "line 4: TTL of api.lab.test"
expect_eq "${#lines[@]}" 4 "exactly four lines of output"
