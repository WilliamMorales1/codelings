# interfaces2: the prefix length is part of the address
#
# `192.0.2.10/24` means: my address is 192.0.2.10 AND everything in
# 192.0.2.0-192.0.2.255 is on this link, reachable directly. From that the
# kernel creates a "connected route" (see `ip route`). Leave the /24 off and
# iproute2 assumes /32: an island that knows no neighbours.
#
# The script below builds a dummy interface (a virtual NIC that goes nowhere,
# perfect for practising). The check asks the kernel how it would reach
# 192.0.2.99 (`ip route get 192.0.2.99`): it should say "directly, via dummy0".
# It currently says "Network is unreachable".
#
# Your task: fix the IPv4 address so dummy0 owns 192.0.2.0/24.

ip link add dummy0 type dummy
ip addr add 192.0.2.10 dev dummy0
ip addr add 2001:db8::10/64 dev dummy0
ip link set dummy0 up
