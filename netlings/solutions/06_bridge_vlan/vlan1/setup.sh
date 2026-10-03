# vlan1: VLAN subinterfaces on a trunk

for h in h1 h2; do
  n=${h#h}
  ip -n $h link add link eth0 name eth0.10 type vlan id 10
  ip -n $h addr add 10.10.0.$n/24 dev eth0.10
  ip -n $h link set eth0.10 up

  ip -n $h link add link eth0 name eth0.20 type vlan id 20
  ip -n $h addr add 10.20.0.$n/24 dev eth0.20
  ip -n $h link set eth0.20 up
done
