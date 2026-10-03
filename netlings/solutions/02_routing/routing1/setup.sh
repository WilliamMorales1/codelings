# routing1: two namespaces and a virtual cable

ip netns add a
ip netns add b

# Creating the pair with both ends already in place also works:
#   ip link add a0 netns a type veth peer name b0 netns b
ip link add a0 type veth peer name b0
ip link set a0 netns a
ip link set b0 netns b

ip -n a addr add 10.0.0.1/24 dev a0
ip -n b addr add 10.0.0.2/24 dev b0

ip -n a link set a0 up
ip -n b link set b0 up
