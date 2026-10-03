#!/usr/bin/env bash
# REQUIRES: ip getent unshare
# HINT
# Create /etc/netns/a/hosts (mkdir -p /etc/netns/a first). Start it as a copy
# of /etc/hosts so localhost keeps working, then append the staging line.
# Leave /etc/hosts itself alone.
source "$NETLINGS_ROOT/checks/lib.sh"
sandbox
newns dns a b
ip -n dns link add br0 type bridge
up dns br0
addr dns br0 10.53.0.53/24
for n in a b; do
  wire "$n" eth0 dns "p$n"
  ip -n dns link set "p$n" master br0
done
addr a eth0 10.53.0.2/24
addr b eth0 10.53.0.3/24
bg dns "$(tmpfile)" netlings serve dns -addr :53 -zone "$NETLINGS_ROOT/checks/04_dns/lab.zone"
wait_listen dns 53
echo "nameserver 10.53.0.53" >/etc/resolv.conf
sandbox_here "Namespaces a and b reach the DNS server at 10.53.0.53. 'bash setup.sh' applies your file."

run_setup
expect_eq "$(ns a getent hosts web.lab.test | awk '{print $1; exit}')" 10.99.0.80 "a sees the staging address"
expect_eq "$(ns b getent hosts web.lab.test | awk '{print $1; exit}')" 10.53.0.80 "b still sees the DNS answer"
expect_match "$(ns a getent hosts localhost | awk '{print $1; exit}')" '^(127.0.0.1|::1)$' "localhost still resolves in a"
grep -q 'web.lab.test' /etc/hosts && fail "/etc/hosts itself was changed: every namespace without its own file sees that"
ok "/etc/hosts itself is unchanged"
