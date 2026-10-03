#!/usr/bin/env bash
# REQUIRES: ip getent unshare
# HINT
# With several `search` lines, only the last one is used. List all domains
# on one line: `search lab.test corp.test`. (`domain X` is the older,
# single-domain form of the same thing, and it also overrides `search`.)
source "$NETLINGS_ROOT/checks/lib.sh"
sandbox
topo_dns
sandbox_here "DNS server at 10.53.0.53. 'cp resolv.conf /etc/resolv.conf', then 'getent hosts web'."

need_file resolv.conf
cp resolv.conf /etc/resolv.conf
expect_eq "$(resolves web)" 10.53.0.80 "short name web"
expect_eq "$(resolves intranet)" 10.54.0.10 "short name intranet"
expect_eq "$(resolves mail.corp.test)" 10.54.0.25 "full names still work"
