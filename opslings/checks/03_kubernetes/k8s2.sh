#!/usr/bin/env bash
# REQUIRES: kubeconform yq
# HINT
# replicas is an integer, not a string: `replicas: 3`.
# Every key/value in spec.selector.matchLabels must also appear in
# spec.template.metadata.labels, e.g. both `app: web` and `tier: frontend`.
source "$OPSLINGS_ROOT/checks/lib.sh"

need_file deployment.yaml
kubeval deployment.yaml
expect_yq deployment.yaml '.spec.replicas' "3" "replicas"
missing=$(yq eval '.spec.template.metadata.labels as $l | .spec.selector.matchLabels | to_entries | map(select($l[.key] != .value)) | map(.key + "=" + .value) | join(", ")' deployment.yaml)
[[ -z "$missing" ]] || fail "selector labels not on the Pod template: $missing"
ok "selector matches the Pod template labels"
expect_yq deployment.yaml '.spec.selector.matchLabels | length > 0' "true" "selector is not empty"
