#!/usr/bin/env bash
# REQUIRES: docker kind kubectl yq
# HINT
# `kubectl describe pod` shows: Failed to pull image "nginx:1.27-alpien" ...
# not found. The tag is 1.27-alpine. Fix it, then apply again and run
#   kubectl --context kind-opslings -n opslings rollout status deploy/web
source "$OPSLINGS_ROOT/checks/lib.sh"

need_file deployment.yaml
d='select(.kind == "Deployment")'
expect_yq deployment.yaml "$d | .spec.template.spec.containers[0].image" "nginx:1.27-alpine" "image in deployment.yaml"
live_part
need_cluster
kc -n opslings get deploy web >/dev/null 2>&1 || fail "no Deployment web in namespace opslings yet: kubectl --context kind-opslings apply -f deployment.yaml"
expect_eq "$(kc -n opslings get deploy web -o jsonpath='{.spec.template.spec.containers[0].image}')" "nginx:1.27-alpine" "image in the cluster (did you apply?)"
wait_for 120 kc -n opslings rollout status deploy/web --timeout=1s || fail "rollout of deploy/web did not finish; kubectl -n opslings get pods"
expect_eq "$(kc -n opslings get deploy web -o jsonpath='{.status.availableReplicas}')" "2" "available replicas"
