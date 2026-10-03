#!/usr/bin/env bash
# REQUIRES: helm yq kubeconform
# HINT
# In _helpers.tpl:
#   {{- define "web.selectorLabels" -}}
#   app.kubernetes.io/name: {{ .Chart.Name }}
#   app.kubernetes.io/instance: {{ .Release.Name }}
#   {{- end }}
# Then everywhere a label block goes, e.g. in the Deployment:
#   metadata:
#     labels:
#       {{- include "web.labels" . | nindent 4 }}
#   ...
#     matchLabels:
#       {{- include "web.selectorLabels" . | nindent 6 }}
# Keep app.kubernetes.io/version out of selectors: it changes every release.
source "$OPSLINGS_ROOT/checks/lib.sh"

need_file Chart.yaml templates/_helpers.tpl templates/deployment.yaml templates/service.yaml
grep -q 'define "web.selectorLabels"' templates/_helpers.tpl || fail 'no define "web.selectorLabels" in templates/_helpers.tpl'
scratch_copy
helm_lint
helm_render out.yaml
d='select(.kind == "Deployment")'
s='select(.kind == "Service")'
sel='{"app.kubernetes.io/instance":"demo","app.kubernetes.io/name":"web"}'
labels='{"app.kubernetes.io/instance":"demo","app.kubernetes.io/managed-by":"Helm","app.kubernetes.io/name":"web","app.kubernetes.io/version":"2.1.0"}'
j() { yq eval -o=json -I=0 "$1 | to_entries | sort_by(.key) | from_entries" out.yaml; }
expect_eq "$(j "$d | .metadata.labels")" "$labels" "Deployment labels"
expect_eq "$(j "$s | .metadata.labels")" "$labels" "Service labels"
expect_eq "$(j "$d | .spec.selector.matchLabels")" "$sel" "Deployment selector (selector labels only)"
expect_eq "$(j "$s | .spec.selector")" "$sel" "Service selector"
missing=$(yq eval "$d | .spec.template.metadata.labels as \$l | .spec.selector.matchLabels | to_entries | map(select(\$l[.key] != .value)) | map(.key) | join(\", \")" out.yaml)
[[ -z "$missing" ]] || fail "Pod template is missing selector labels: $missing"
ok "Pod template carries the selector labels"
kubeval out.yaml
