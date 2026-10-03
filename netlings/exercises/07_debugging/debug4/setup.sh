# debug4: simulating a bad network with tc netem
#
# `tc` controls the queueing discipline (qdisc) of an interface: how packets
# wait before being sent. The netem qdisc fakes WAN problems on the way OUT
# of an interface: delay, jitter, loss, duplication, reordering. Perfect for
# testing "does my app survive 300ms and 5% loss?" on a laptop.
#     tc qdisc add dev IF root netem delay 80ms 10ms loss 2%
#     tc qdisc show dev IF         tc -s qdisc (with counters)
#     tc qdisc del dev IF root     back to normal
#
# The check wires a (10.0.0.1) <-> b (10.0.0.2) and then pings b from a. The
# round-trip time must be about 100ms: 100ms delay on a's outgoing side,
# nothing added on the way back.
#
# Your task: the qdisc below is installed and ping is still instant. Read
# `tc qdisc show` closely, and mind the units.

ip netns exec a tc qdisc add dev a0 root netem delay 100
