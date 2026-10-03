# bridge1: a software switch

ip -n sw link add br0 type bridge
ip -n sw link set p1 master br0
ip -n sw link set p2 master br0
ip -n sw link set p3 master br0
ip -n sw link set br0 up
