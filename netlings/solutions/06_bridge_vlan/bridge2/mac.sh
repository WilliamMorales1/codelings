# bridge2: ARP and the neighbour table

ping -c1 -W1 10.0.0.3 >/dev/null
ip -j neigh show 10.0.0.3 | jq -r '.[0].lladdr'
