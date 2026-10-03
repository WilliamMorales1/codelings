#!/usr/bin/env bash
# REQUIRES: kubeconform yq
# HINT
# Pods live in the core API group, whose apiVersion is just `v1`
# (apps/v1 is for Deployments, StatefulSets, ...).
# Ports are a list of objects:
#   ports:
#     - containerPort: 80
source "$OPSLINGS_ROOT/checks/lib.sh"

need_file pod.yaml
kubeval pod.yaml
expect_yq pod.yaml '.apiVersion + " " + .kind' "v1 Pod" "apiVersion and kind"
expect_yq pod.yaml '.metadata.name' "web" "Pod name"
expect_yq pod.yaml '.spec.containers[0].image' "nginx:1.27-alpine" "image"
expect_yq pod.yaml '.spec.containers[0].ports[0].containerPort' "80" "containerPort"
