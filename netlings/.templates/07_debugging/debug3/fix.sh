# debug3: follow the path
#
# Ticket: "a (10.1.0.2) cannot reach b (10.3.0.2). Worked yesterday."
#
#   a 10.1.0.2 --- [r1] --- 10.12.0.0/24 --- [r2] --- b 10.3.0.2
#
# There is exactly one wrong setting somewhere on the routers. Find it:
#     netlings sandbox debug3
#     ip netns exec a ping -c2 10.3.0.2        what error? from whom?
#     ip netns exec a tracepath -n 10.3.0.2    (or traceroute -n, if installed)
#     ip -n r1 route; ip -n r2 route; ip -n r2 route get 10.3.0.2
# tracepath/traceroute send packets with TTL 1, 2, 3... and every router that
# drops one for "TTL exceeded" reveals itself. A path that bounces between the
# same two addresses is a routing loop.
#
# Your task: write the command(s) that repair it into this script (the check
# runs it in the broken network). Don't rebuild the network; fix the one thing.

