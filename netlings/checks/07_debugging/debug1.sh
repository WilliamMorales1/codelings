#!/usr/bin/env bash
# REQUIRES: bash
# HINT
# grep helps: grep 'A?' / grep '\*' for DNS, grep 'Flags \[R' for the reset,
# grep '5432' for the port that only ever sees [S] from the client. The HTTP
# response line says "HTTP: HTTP/1.1 ...". The first [F.] line names its sender
# on the left of the ">".
source "$NETLINGS_ROOT/checks/lib.sh"

expect_answer dns_answer cb5f37b4762871e6bbeccee663cb332438340c469160c634566ecc7c7e01009f "A record in the DNS reply"
expect_answer http_client_port ea30790cb0936d55028277b1a842650c73464680563d99b2d022c2a67e2471a3 "ephemeral port of the port-80 connection"
expect_answer http_status 27badc983df1780b60c2b3fa9d3a19a00e46aac798451f0febdca52920faaddf "status line of the response"
expect_answer refused_port e998d857e5637aa94c02419c98be82013f1571b2f4be936b9c79eae57c17dd2f "port answered with [R.]"
expect_answer filtered_port 4aeb7ad6d5d37a041c4c5ce6562bf9e3caf05a42d931cef4d9e2a60ca623194d "port that never answers"
expect_answer filtered_syns 4e07408562bedb8b60ce05c1decfe3ad16b72230967de01f640b7e4729b49fce "SYN retransmissions"
expect_answer first_fin f5047344122f0dee9974ba6761e61c6b8649e1f3968d13a635ebbf7be53a3a0d "sender of the first [F.]"
