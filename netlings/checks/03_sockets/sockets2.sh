#!/usr/bin/env bash
# REQUIRES: ss ip unshare
# HINT
# Three changes: -H for no header, and a filter comparing the source (local)
# port: '( sport >= :8000 and sport <= :8999 )'. -t already limits it to TCP
# and -l to listening sockets.
source "$NETLINGS_ROOT/checks/lib.sh"
sandbox
ip link set lo up
ip link add eth0 type dummy && ip link set eth0 up && ip addr add 10.0.0.5/24 dev eth0
log=$(tmpfile)
bg - "$log" netlings serve echo -addr :22
bg - "$log" netlings serve http -addr :8080
bg - "$log" netlings serve http -addr 127.0.0.1:8443
bg - "$log" netlings serve echo -addr 10.0.0.5:8999
bg - "$log" netlings serve http -addr :9090
bg - "$log" netlings serve http -addr :18080
bg - "$log" netlings serve udp -addr :8053 -out /dev/null
for p in 22 8080 8443 8999 9090 18080 8053; do wait_listen - $p; done
# an established connection on 8080 that must not show up either
exec 3<>/dev/tcp/127.0.0.1/8080
sandbox_here "Servers are running here. Try 'ss -tuln', then 'bash query.sh'."

capture query.sh
got=$(awk '{print $4}' <<<"$OUT" | LC_ALL=C sort | tr '\n' ' ')
expect_eq "$got" "*:8080 10.0.0.5:8999 127.0.0.1:8443 " "local addresses printed (sorted)"
