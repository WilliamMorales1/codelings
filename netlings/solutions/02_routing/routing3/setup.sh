# routing3: a router has to be allowed to forward
# net.ipv4.* sysctls are per network namespace; set it inside r.

ip netns exec r sysctl -w net.ipv4.ip_forward=1
