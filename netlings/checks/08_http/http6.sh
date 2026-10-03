#!/usr/bin/env bash
# REQUIRES: ip curl jq unshare
# HINT
# Replace -k with --cacert /run/netlings/ca.pem . Without either, curl fails
# with exit code 60, "unable to get local issuer certificate": that error is
# the certificate check doing its job. Also try https://10.0.0.2/ with the
# CA: it fails too, because the certificate is for the NAME secure.lab.test.
source "$NETLINGS_ROOT/checks/lib.sh"
sandbox
topo_web
sandbox_here "b serves https://secure.lab.test/ (CA: $CA_PEM). Try 'ip netns exec a bash fetch.sh'."

need_file fetch.sh
if grep -v '^[[:space:]]*#' fetch.sh | grep -qE '(^|[[:space:]])(-[a-zA-Z]*k[a-zA-Z]*|--insecure)([[:space:]]|$)'; then
  fail "fetch.sh still switches certificate verification off (-k / --insecure)"
fi
ok "no -k / --insecure"
capture fetch.sh a
expect_eq "$(jq -r .tls <<<"$OUT" 2>/dev/null)" true "got /whoami over HTTPS"
expect_eq "$(jq -r .host <<<"$OUT")" secure.lab.test "asked for secure.lab.test"
