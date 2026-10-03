#!/usr/bin/env bash
# REQUIRES: tcpdump
# HINT
# Three conditions, joined with `and`: the destination is 10.0.0.2
# (`dst host 10.0.0.2`), the destination port is 80 (`dst port 80`), and the
# packet is a bare SYN (`tcp[tcpflags] == tcp-syn`; a SYN-ACK also has the
# SYN bit, so `& tcp-syn != 0` is not enough on its own).
source "$NETLINGS_ROOT/checks/lib.sh"
need_file filter.txt traffic.pcap
f=$(tmpfile)
grep -v '^[[:space:]]*#' filter.txt >"$f"
out=$(tcpdump -n -r traffic.pcap -F "$f" 2>&1 >/dev/null | grep -iv 'reading from' ; true)
got=$(tcpdump -n -r traffic.pcap -F "$f" 2>/dev/null) || fail "tcpdump rejected the filter: $out"
rm -f "$f"
n=$(grep -c . <<<"$got")
expect_eq "$n" 4 "number of matching packets"
ports=$(grep -oE '10\.0\.0\.1\.[0-9]+ > 10\.0\.0\.2\.80: Flags \[S\],' <<<"$got" | cut -d. -f5 | cut -d' ' -f1 | sort | tr '\n' ' ')
expect_eq "$ports" "35292 35296 35298 35312 " "the four client SYNs to 10.0.0.2:80"
