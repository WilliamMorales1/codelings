#!/usr/bin/env bash
# REQUIRES: redis
# HINT
# Strip the \r, then compare the whole field name:
#   $REDIS_CLI INFO memory | tr -d '\r' | awk -F: '$1 == "used_memory" { print $2 }'
# The clients field is connected_clients.
source "$REDISLINGS_ROOT/checks/lib.sh"

need_file report.sh
start_redis
listen - 5 <<<"SUBSCRIBE keepalive" || fail "test client did not connect"
export_cli
got=$(bash ./report.sh 2>&1)
expect_eq "$(wc -l <<<"$got" | tr -d ' ')" "2" "exactly two lines"
expect_eq "$(grep -c $'\r' <<<"$got")" "0" "no stray carriage returns"
mem=$(sed -n 's/^used_memory=//p' <<<"$got")
real=$(r INFO memory | tr -d '\r' | awk -F: '$1 == "used_memory" { print $2 }')
expect_between "${mem:-none}" $((real * 8 / 10)) $((real * 12 / 10)) "used_memory is the server's (about $real bytes)"
expect_eq "$(sed -n 's/^clients=//p' <<<"$got")" "2" "clients counts the connected clients (a listener plus the script itself)"
