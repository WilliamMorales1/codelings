# routing1: two namespaces and a virtual cable
#
# A network namespace is a complete, separate network stack: its own
# interfaces, addresses, routes and firewall. `ip netns add NAME` creates one;
# `ip netns exec NAME CMD` (or `ip -n NAME ...`) runs something inside it.
# A veth pair is a virtual cable: whatever goes in one end comes out the other.
#
# Goal (the check starts from an empty sandbox):
#     namespace a: a0 10.0.0.1/24  <--- veth --->  namespace b: b0 10.0.0.2/24
# and a can ping b, and b can ping a.
#
# Your task: this script was written in a hurry. Fix it. Its errors (the
# check shows them) are a good start, but not the whole story.

ip netns add a
ip netns add b

ip link add a0 type veth peer name b0
ip link set a0 netns a
ip link set b0 netns a

ip -n a addr add 10.0.0.1/24 dev a0
ip -n b addr add 10.0.0.2/24 dev b0

ip -n a link set a0 up
