# interfaces1: link state versus addresses
# The address was fine; the link was DOWN. Nothing is delivered over a down link, not even to yourself.

ip link set lo up
ip addr add 10.255.0.1/32 dev lo
