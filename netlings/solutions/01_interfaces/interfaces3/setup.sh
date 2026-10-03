# interfaces3: MTU must match on both ends of a link

ip -n a link set a0 mtu 9000
ip -n b link set b0 mtu 9000
