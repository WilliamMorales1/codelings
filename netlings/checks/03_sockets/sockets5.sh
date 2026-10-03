#!/usr/bin/env bash
# REQUIRES: ss ip unshare
# HINT
# `ss -Htlnp 'sport = :7002'` gives exactly one line. Then extract the number
# after pid=, for example with  sed -E 's/.*pid=([0-9]+).*/\1/'  or
# grep -oP 'pid=\K[0-9]+'.
source "$NETLINGS_ROOT/checks/lib.sh"
sandbox
ip link set lo up
log=$(tmpfile)
bg - "$log" netlings serve echo -addr :17002
bg - "$log" netlings serve echo -addr :7001
bg - "$log" netlings serve echo -addr :7002
want=$!
bg - "$log" netlings serve echo -addr :7003
bg - "$log" netlings serve udp -addr :7002 -out /dev/null
bg - "$log" netlings serve echo -addr 127.0.70.2:8000
for p in 17002 7001 7002 7003 8000; do wait_listen - $p; done
sandbox_here "Servers are running. Try 'ss -tulnp', then 'bash pid.sh'."

capture pid.sh
expect_eq "$OUT" "$want" "pid.sh printed the PID of the TCP :7002 listener"
