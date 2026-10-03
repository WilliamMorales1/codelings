# vlan2: a VLAN-aware bridge
#
# Instead of subinterfaces, a bridge can itself sort ports into VLANs (like a
# managed switch). Turn it on with `vlan_filtering 1`, then per port:
#     bridge vlan add dev PORT vid 10 pvid untagged
# pvid = untagged frames arriving on this port belong to VLAN 10;
# untagged = frames of VLAN 10 leave this port without a tag.
# Together that makes an "access port": the host behind it knows nothing
# about VLANs. `bridge vlan show` lists what each port carries.
#
# The check builds the three-host switch from bridge1, br0 already working,
# all hosts in 10.0.0.0/24. Wanted: h1 and h2 in VLAN 10, h3 alone in VLAN
# 20. So h1 <-> h2 ping works, but nobody reaches h3, same subnet or not.
#
# Your task: h1 and h2 cannot talk. Compare the p1 and p2 lines.
# (`bridge -n sw ...` runs the bridge tool inside namespace sw.)

ip -n sw link set br0 type bridge vlan_filtering 1
bridge -n sw vlan add dev p1 vid 10 pvid untagged
bridge -n sw vlan add dev p2 vid 10
bridge -n sw vlan add dev p3 vid 20 pvid untagged
