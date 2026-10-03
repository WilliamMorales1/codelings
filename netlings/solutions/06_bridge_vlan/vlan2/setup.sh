# vlan2: a VLAN-aware bridge

ip -n sw link set br0 type bridge vlan_filtering 1
bridge -n sw vlan add dev p1 vid 10 pvid untagged
bridge -n sw vlan add dev p2 vid 10 pvid untagged
bridge -n sw vlan add dev p3 vid 20 pvid untagged
# Every port starts in VLAN 1; take them out so nothing leaks through it.
for p in p1 p2 p3; do
  bridge -n sw vlan del dev $p vid 1
done
