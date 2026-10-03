#!/usr/bin/env bash
# REQUIRES: gawk
# HINT
# /BEGIN/, /END/ also matches the private key block. Anchor on the whole
# certificate marker: /^-----BEGIN CERTIFICATE-----$/, /^-----END CERTIFICATE-----$/
# A pattern with no action prints the line.
source "$TEXTLINGS_ROOT/checks/lib.sh"

expect_out awk expected.txt -- bundle.pem
expect_out --label "same program on a second, hidden input" awk "$FIX/expected.txt" -- "$FIX/bundle.pem"
