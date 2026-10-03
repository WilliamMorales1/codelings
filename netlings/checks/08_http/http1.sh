#!/usr/bin/env bash
# REQUIRES: bash
# HINT
# grep '^>' shows the requests, grep '^<' the responses. "Trying" and
# "Established connection" name the address. "Reusing existing ... connection"
# means no new TCP connection. The issuer line is in the "Server certificate"
# block. Answers are compared ignoring case and spaces.
source "$NETLINGS_ROOT/checks/lib.sh"

expect_answer server_ip cb5f37b4762871e6bbeccee663cb332438340c469160c634566ecc7c7e01009f "address from the 'Trying' line"
expect_answer tls_version 38276f132ad8da76647ef5d3c59b548d4ae256245b2dd6c631984f56cf985343 "from 'SSL connection using'"
expect_answer http_version 46179e1c8e2c3f841a9da7599aabad957dfd14d96704a68f24280290e381261a "the status lines say HTTP/2"
expect_answer first_status c3ea99f86b2f8a74ef4145bb245155ff5f91cd856f287523481c15a1959d5fd1 "first '<' status line"
expect_answer requests 4e07408562bedb8b60ce05c1decfe3ad16b72230967de01f640b7e4729b49fce "GET /old, /moved, /final"
expect_answer connections 6b86b273ff34fce19d6b804eff5a3f5747ada4eaa22f1d49c01e52ddb7875b4b "the connection was reused"
expect_answer issuer_cn 329a048d40f427722527efddf4ade1905cca76d14db73b025be2f3f2684a0c42 "issuer: ... CN=..."
expect_answer body bc85bbb7425c3f06a2f18e850d1ebd250912cdf16269fdf1a7d0f51ac3e5e73b "last line of the output"
