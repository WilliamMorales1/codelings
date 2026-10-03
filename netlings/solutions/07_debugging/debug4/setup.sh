# debug4: simulating a bad network with tc netem
# A bare number is microseconds to tc: "100" was 100us.

ip netns exec a tc qdisc add dev a0 root netem delay 100ms
