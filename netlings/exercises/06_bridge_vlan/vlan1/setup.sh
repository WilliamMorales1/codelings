# vlan1: VLAN subinterfaces on a trunk
#
# A VLAN splits one cable/switch into several separate LANs. Frames carry an
# 802.1Q tag with the VLAN ID (1-4094). On Linux, `eth0.10` is a subinterface
# that tags everything it sends with ID 10 and only receives frames tagged 10:
#     ip link add link eth0 name eth0.10 type vlan id 10
#
# The check cables h1's eth0 directly to h2's eth0 (a "trunk" carrying
# several VLANs), with no addresses on eth0 itself. Wanted:
#     VLAN 10: h1 eth0.10 10.10.0.1/24  <->  h2 eth0.10 10.10.0.2/24
#     VLAN 20: h1 eth0.20 10.20.0.1/24  <->  h2 eth0.20 10.20.0.2/24
#
# Your task: VLAN 10 does not work (look at the IDs: the interface NAME is
# just a name, the ID is what goes on the wire), and VLAN 20 is still a TODO.

ip -n h1 link add link eth0 name eth0.10 type vlan id 10
ip -n h1 addr add 10.10.0.1/24 dev eth0.10
ip -n h1 link set eth0.10 up

ip -n h2 link add link eth0 name eth0.10 type vlan id 100
ip -n h2 addr add 10.10.0.2/24 dev eth0.10
ip -n h2 link set eth0.10 up

# TODO: VLAN 20
