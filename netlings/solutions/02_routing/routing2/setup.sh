# routing2: gateways must be on-link

ip -n a route add default via 10.1.0.1
# The gateway is r's address on b's own subnet: 10.2.0.1, not 10.1.0.1.
ip -n b route add 10.1.0.0/24 via 10.2.0.1
