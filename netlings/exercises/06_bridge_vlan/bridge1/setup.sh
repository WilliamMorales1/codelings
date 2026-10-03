# bridge1: a software switch
#
# A Linux bridge is a switch in software: frames that arrive on one port go
# out of the port where the destination MAC lives (it learns MACs as it goes).
# Docker, libvirt and LXC all put their containers/VMs on one.
#
# The check makes namespace sw (the switch) and three hosts, each cabled to it:
#     h1 10.0.0.1 --- p1 \
#     h2 10.0.0.2 --- p2 -[sw]   (p1..p3 are veth ends inside sw)
#     h3 10.0.0.3 --- p3 /
# The cables are plugged in, but sw is not switching yet.
#
# Your task: create bridge br0 in sw with all three ports, so every host can
# ping every other host. The script below is almost there; see the check's
# output for what is still missing.

ip -n sw link add br0 type bridge
ip -n sw link set p1 master br0
ip -n sw link set p2 master br0
