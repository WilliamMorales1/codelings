# interfaces1: link state versus addresses
#
# An interface has two separate things you can get wrong: whether the link
# is UP, and which addresses sit on it. `ip link` shows the first, `ip addr`
# the second.
#
# A colleague wants 10.255.0.1/32 on the loopback interface (a "service
# address" that stays reachable no matter which NIC is up; routers do this for
# their router-id). They ran the line below in a fresh namespace, but
# `ping 10.255.0.1` fails, and so does `ping 127.0.0.1`.
#
# Your task: make both pings work. Keep the /32 address.
#
# Try it:  netlings sandbox interfaces1   then   bash setup.sh; ip addr show lo

ip addr add 10.255.0.1/32 dev lo
