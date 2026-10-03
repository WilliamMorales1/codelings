#!/usr/bin/env bash
# REQUIRES: ip openssl unshare
# HINT
# s_client keeps the connection open and waits for you to type on stdin. Give
# it an empty stdin so it hangs up right after the handshake:
#   openssl s_client ... </dev/null 2>/dev/null | openssl x509 -noout -subject -issuer
# (or `-brief`/`echo | openssl s_client ...`).
source "$NETLINGS_ROOT/checks/lib.sh"
sandbox
topo_web
sandbox_here "b (10.0.0.2) serves HTTPS for secure.lab.test. Try 'ip netns exec a bash cert.sh'."

# Hand the script a terminal-like stdin that never ends, the way an interactive run behaves.
err=$(tmpfile)
fifo=/run/netlings/stdin
mkfifo "$fifo"
exec 4<>"$fifo"
OUT=$(ns a timeout 5 bash cert.sh 2>"$err" <&4)
rc=$?
[[ $rc == 124 ]] && fail "cert.sh was still running after 5 seconds"
[[ $rc == 0 ]] || { sed 's/^/  | /' "$err"; fail "cert.sh exited with status $rc"; }
mapfile -t lines <<<"$OUT"
expect_match "${lines[0]:-}" '^subject=.*CN ?= ?secure\.lab\.test' "line 1: the subject"
expect_match "${lines[1]:-}" '^issuer=.*CN ?= ?netlings test CA' "line 2: the issuer"
