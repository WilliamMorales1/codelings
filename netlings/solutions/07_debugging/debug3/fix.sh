# debug3: follow the path
# r2 had a leftover, more specific route (10.3.0.0/25) pointing back at r1.
# It beats r2's own connected 10.3.0.0/24, so b's half of the subnet loops
# between the routers until the TTL runs out.

ip -n r2 route del 10.3.0.0/25
