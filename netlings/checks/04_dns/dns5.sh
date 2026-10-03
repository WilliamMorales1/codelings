#!/usr/bin/env bash
# REQUIRES: ip getent unshare
# HINT
# Sources are tried left to right and the first one that knows the name wins.
# DNS knows api.lab.test, so /etc/hosts is never consulted. Swap them:
# `hosts: files dns`.
source "$NETLINGS_ROOT/checks/lib.sh"
sandbox
topo_dns
echo "nameserver 10.53.0.53" >/etc/resolv.conf
printf '10.99.0.81\tapi.lab.test\n' >>/etc/hosts
sandbox_here "/etc/hosts pins api.lab.test; DNS at 10.53.0.53. 'cp nsswitch.conf /etc/nsswitch.conf' applies your file."

need_file nsswitch.conf
cp nsswitch.conf /etc/nsswitch.conf
expect_eq "$(resolves api.lab.test)" 10.99.0.81 "api.lab.test comes from /etc/hosts"
expect_eq "$(resolves web.lab.test)" 10.53.0.80 "web.lab.test still comes from DNS"
expect_eq "$(id -un)" root "user lookups still work (passwd line intact)"
