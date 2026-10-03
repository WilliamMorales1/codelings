# routing4: static routes, and the way back

ip -n r1 route add 10.3.0.0/24 via 10.12.0.2
ip -n r2 route add 10.1.0.0/24 via 10.12.0.1
