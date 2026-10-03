# interfaces3: MTU must match on both ends of a link
#
# The check builds two namespaces joined by a veth pair (a virtual cable):
#     a: a0 10.0.0.1/24  <------>  b: b0 10.0.0.2/24
# `ip -n a ...` is short for "run this ip command inside namespace a".
#
# The storage team wants jumbo frames (MTU 9000) on this link. After the
# change below, small pings still work, but a full-size one
#     ip netns exec a ping -M do -s 8972 10.0.0.2
# (8972 bytes of data + 8 ICMP + 20 IP header = 9000, -M do = do not fragment)
# silently disappears. That is the classic MTU mismatch: small packets fine,
# big ones vanish.
#
# Your task: make 9000-byte packets work in both directions.

ip -n a link set a0 mtu 9000
