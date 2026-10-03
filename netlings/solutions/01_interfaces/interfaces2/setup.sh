# interfaces2: the prefix length is part of the address

ip link add dummy0 type dummy
ip addr add 192.0.2.10/24 dev dummy0
ip addr add 2001:db8::10/64 dev dummy0
ip link set dummy0 up
