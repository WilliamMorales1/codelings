#!/usr/bin/env bash
# REQUIRES: kubeconform yq
# HINT
# Under envFrom the field is `configMapRef`, not `configMap` (that one is for
# volumes). And the LOG_LEVEL reference must use the ConfigMap's real name
# and key:  name: logging, key: level.
source "$OPSLINGS_ROOT/checks/lib.sh"

need_file config.yaml
kubeval config.yaml
c='select(.kind == "Deployment") | .spec.template.spec.containers[0]'
expect_yq config.yaml "$c | .envFrom[0].configMapRef.name" "app-config" "envFrom loads app-config"
expect_yq config.yaml "$c | .env[] | select(.name == \"LOG_LEVEL\") | .valueFrom.configMapKeyRef.name" "logging" "LOG_LEVEL comes from the logging ConfigMap"
expect_yq config.yaml "$c | .env[] | select(.name == \"LOG_LEVEL\") | .valueFrom.configMapKeyRef.key" "level" "LOG_LEVEL uses the key 'level'"
# yq quirk: a trailing literal/variable is emitted even for an empty input, so outputs start from `.`.
dangling=$(yq eval-all '
  [select(.kind == "ConfigMap")] as $cms |
  select(.kind == "Deployment") | .spec.template.spec.containers[] |
  ((.env // [])[] | .valueFrom.configMapKeyRef | select(.) | . as $r | $r.key as $k |
     select(([$cms[] | select(.metadata.name == $r.name and (.data | has($k)))] | length) == 0) |
     .name + "/" + .key),
  ((.envFrom // [])[] | .configMapRef | select(.) | . as $r |
     select(([$cms[] | select(.metadata.name == $r.name)] | length) == 0) | .name)
' config.yaml)
[[ -z "$dangling" ]] || fail "references to ConfigMaps/keys that do not exist: $dangling"
ok "every ConfigMap reference resolves"
