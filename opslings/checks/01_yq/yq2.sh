#!/usr/bin/env bash
# REQUIRES: yq
# HINT
# Kubernetes kinds are CamelCase: "Deployment", not "deployment".
# Combine conditions inside one select:
#   select(.kind == "Deployment" and .spec.replicas >= 2) | .metadata.name
source "$OPSLINGS_ROOT/checks/lib.sh"

need_file query.yq manifests.yaml
got=$(yq -N --from-file query.yq manifests.yaml 2>&1) || fail "yq error: $got"
expect_eq "$got" $'api\nweb' "Deployments with >= 2 replicas in manifests.yaml"
got=$(yq -N --from-file query.yq "$OPSLINGS_ROOT/checks/01_yq/fixtures/yq2-other.yaml" 2>&1)
expect_eq "$got" "gateway" "same query on other manifests (StatefulSets do not count)"
