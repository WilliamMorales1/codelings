#!/usr/bin/env bash
# REQUIRES: kubeconform yq
# HINT
# Copy the labels from the Deployment's *Pod template*:
#   selector:
#     app: api
# and point targetPort at the container port's name:
#   targetPort: http
source "$OPSLINGS_ROOT/checks/lib.sh"

need_file service.yaml deployment.yaml
kubeval service.yaml deployment.yaml
expect_yq service.yaml '.spec.ports[0].port' "80" "Service port"
expect_yq service.yaml '.spec.ports[0].targetPort' "http" "targetPort is the named port"
bad=$(yq eval-all '(select(fi == 0) | .spec.template.metadata.labels) as $l | select(fi == 1) | .spec.selector | to_entries | map(select($l[.key] != .value)) | map(.key + "=" + .value) | join(", ")' deployment.yaml service.yaml)
[[ -z "$bad" ]] || fail "Service selector does not match the Pods: $bad"
expect_yq service.yaml '.spec.selector | length > 0' "true" "selector is not empty"
ok "Service selects the api Pods"
names=$(yq eval '.spec.template.spec.containers[].ports[].name' deployment.yaml)
grep -qx "$(yq eval '.spec.ports[0].targetPort' service.yaml)" <<<"$names" || fail "targetPort does not name a container port"
ok "targetPort exists on the container"
