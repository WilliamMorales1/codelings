#!/usr/bin/env bash
# REQUIRES: kubeconform yq
# HINT
# Easiest fix for the Secret: rename `data:` to `stringData:`.
# In a volume the field is `secretName`, not `name`:
#   volumes:
#     - name: creds
#       secret:
#         secretName: db-creds
# The volumeMount's `name` must equal the volume's `name`, and add
# `readOnly: true` to the mount.
source "$OPSLINGS_ROOT/checks/lib.sh"

need_file secret.yaml
kubeval secret.yaml
s='select(.kind == "Secret")'
p='select(.kind == "Pod")'
expect_yq secret.yaml "$s | .metadata.name" "db-creds" "Secret name"
while IFS= read -r v; do
  [[ -z "$v" ]] && continue
  printf '%s' "$v" | base64 -d >/dev/null 2>&1 || fail "'$v' under data: is not valid base64 (use stringData: for plain text)"
done < <(yq eval "$s | .data // {} | .[]" secret.yaml)
keys=$(yq eval "$s | ((.data // {}) * (.stringData // {})) | keys | sort | join(\",\")" secret.yaml)
expect_eq "$keys" "password,username" "Secret keys"
mount_name=$(yq eval "$p | .spec.containers[0].volumeMounts[] | select(.mountPath == \"/etc/db\") | .name" secret.yaml)
[[ -n "$mount_name" ]] || fail "nothing is mounted at /etc/db"
expect_yq secret.yaml "$p | .spec.volumes[] | select(.name == \"$mount_name\") | .secret.secretName" "db-creds" "volume '$mount_name' is the db-creds Secret"
expect_yq secret.yaml "$p | .spec.containers[0].volumeMounts[] | select(.mountPath == \"/etc/db\") | .readOnly" "true" "mount is readOnly"
