# routing4: static routes, and the way back
#
# Two routers in a row. The check wires this up and turns forwarding on:
#
#   a 10.1.0.2 --- 10.1.0.1 [r1] 10.12.0.1 --- 10.12.0.2 [r2] 10.3.0.1 --- 10.3.0.2 c
#
# a's default route goes to r1, c's to r2. Each router only knows the two
# subnets it is plugged into. Someone taught r1 how to reach 10.3.0.0/24,
# and `ip netns exec a ping 10.3.0.2` still fails: the request reaches c, the
# reply does not come back. Every packet needs a route in BOTH directions.
#
# Your task: add the missing static route. No default routes on the routers.

ip -n r1 route add 10.3.0.0/24 via 10.12.0.2
