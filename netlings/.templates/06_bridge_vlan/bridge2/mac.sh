# bridge2: ARP and the neighbour table
#
# Before h1 can send an IP packet to 10.0.0.3 on the same LAN, it has to know
# 10.0.0.3's MAC address. It broadcasts an ARP request ("who has 10.0.0.3?"),
# and caches the reply in its neighbour table: `ip neigh` (the old `arp -n`).
#
# The check runs this script inside h1 (on the same switch as bridge1, br0
# already working). It must print the MAC address of 10.0.0.3, as h1 learned it,
# like 5a:2e:...: nothing else.
#
# Your task: this prints the wrong MAC.

ping -c1 -W1 10.0.0.3 >/dev/null
ip link show eth0 | awk '/link\/ether/ {print $2}'
