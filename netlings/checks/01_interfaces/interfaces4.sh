#!/usr/bin/env bash
# REQUIRES: jq
# HINT
# admin_down: the one whose flags lack "UP". no_carrier: has "UP" and
# "NO-CARRIER". Link-local IPv6 addresses start with fe80. A /16 leaves 16 bits
# for hosts. "master" names the bridge an interface is enslaved to.
source "$NETLINGS_ROOT/checks/lib.sh"

expect_answer admin_down 1631f68479019a91dd843158b5b6d63068c2db23317b430669221be63570f4e7 "the interface without the UP flag"
expect_answer no_carrier 297a8b73df18b883559121f389981465a91e18da9d4f605450cb420d9560e2a9 "UP, but NO-CARRIER"
expect_answer wlan0_ipv4 b569a87af968c036e287f579eeb7585d2ad6b5c96c0a4ed4adfec63f54391e01 "address/prefixlen of wlan0"
expect_answer smallest_mtu 5f82c3bf2a2e79345b983d24ac6beb8a9ae6bc675a6f977403fd4afd382aa71c "interface with the smallest mtu"
expect_answer docker0_size 0f255ec16482c343fd099ba9668863778be40dc166a6856b1d470e0bc97cc6fd "2^16"
expect_answer link_local_count 4e07408562bedb8b60ce05c1decfe3ad16b72230967de01f640b7e4729b49fce "count of fe80:: addresses"
expect_answer veth_master 297a8b73df18b883559121f389981465a91e18da9d4f605450cb420d9560e2a9 "the veth's master"
