# routing3: a router has to be allowed to forward
#
#     a: 10.1.0.2 --- 10.1.0.1 [r] 10.2.0.1 --- b: 10.2.0.2
#
# This time a and b have their default routes (the check sets them), but by
# default Linux is a host, not a router: a packet arriving on r0 for somebody
# else gets dropped. The switch is the sysctl net.ipv4.ip_forward.
#
# Someone enabled it with the line below, and still nothing gets through.
# Remember that every namespace has its own network stack... including most of
# /proc/sys/net.
#
# Your task: make a able to ping b. Forwarding must be on where it is needed
# and nowhere else (the sandbox's own namespace is not a router).

sysctl -w net.ipv4.ip_forward=1
