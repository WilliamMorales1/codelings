# routing2: gateways must be on-link
#
# The check builds two subnets with a router between them (forwarding is on):
#
#     a: a0 10.1.0.2/24 --- r0 10.1.0.1  [r]  r1 10.2.0.1 --- b: b0 10.2.0.2/24
#
# Neither a nor b has any route beyond its own subnet yet. a gets a default
# route. b should NOT get a default route (it is a locked-down database host);
# it gets one specific route back to a's subnet instead.
#
# Right now `ip netns exec a ping 10.2.0.2` gets no answer. The b line below
# says "10.1.0.0/24 is right here on b0", so b tries to ARP for 10.1.0.2 on its
# own wire, where nobody answers.
#
# Your task: give b a proper route to 10.1.0.0/24, via the router.

ip -n a route add default via 10.1.0.1
ip -n b route add 10.1.0.0/24 dev b0
