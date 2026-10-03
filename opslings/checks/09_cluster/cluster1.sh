#!/usr/bin/env bash
# REQUIRES: docker kind kubectl yq
# HINT
# The name must be exactly `opslings`, and kind calls the second role
# `worker`:
#   nodes:
#     - role: control-plane
#     - role: worker
# If you created a cluster with the old name, remove it:
#   kind delete cluster --name ops-lings
source "$OPSLINGS_ROOT/checks/lib.sh"

need_file kind.yaml
expect_yq kind.yaml '.kind + " " + .apiVersion' "Cluster kind.x-k8s.io/v1alpha4" "kind config header"
expect_yq kind.yaml '.name' "opslings" "cluster name"
expect_yq kind.yaml '[.nodes[].role] | join(",")' "control-plane,worker" "node roles"
live_part
need_cluster
nodes=$(kc get nodes --no-headers 2>&1)
expect_eq "$(wc -l <<<"$nodes" | tr -d ' ')" "2" "number of nodes"
wait_for 90 kc wait --for=condition=Ready nodes --all --timeout=1s || fail "not all nodes are Ready:"$'\n'"$nodes"
ok "both nodes are Ready"
expect_eq "$(kc get nodes -l '!node-role.kubernetes.io/control-plane' --no-headers | wc -l | tr -d ' ')" "1" "one worker node"
