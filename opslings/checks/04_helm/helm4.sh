#!/usr/bin/env bash
# REQUIRES: helm yq kubeconform
# HINT
#           env:
#             {{- range $name, $value := .Values.env }}
#             - name: {{ $name }}
#               value: {{ $value | quote }}
#             {{- end }}
# and wrap all of templates/ingress.yaml in
#   {{- if .Values.ingress.enabled }}
#   ...
#   {{- end }}
source "$OPSLINGS_ROOT/checks/lib.sh"

need_file Chart.yaml values.yaml templates/deployment.yaml templates/ingress.yaml
scratch_copy
helm_lint
helm_render out.yaml
expect_eq "$(yq eval-all '[select(.kind == "Ingress")] | length' out.yaml)" "0" "no Ingress by default"
env=$(yq eval -o=json -I=0 'select(.kind == "Deployment") | .spec.template.spec.containers[0].env' out.yaml)
expect_eq "$env" '[{"name":"CHECKOUT_V2","value":"true"},{"name":"LOG_LEVEL","value":"info"},{"name":"REGION","value":"eu-west-1"},{"name":"WORKERS","value":"4"}]' "env rendered from the map, values as strings"
kubeval out.yaml
helm_render on.yaml --set ingress.enabled=true --set ingress.host=beta.example.com --set env.EXTRA=1
expect_eq "$(yq eval-all '[select(.kind == "Ingress")] | length' on.yaml)" "1" "Ingress with ingress.enabled=true"
expect_yq on.yaml 'select(.kind == "Ingress") | .spec.rules[0].host' "beta.example.com" "Ingress host from values"
expect_yq on.yaml 'select(.kind == "Deployment") | .spec.template.spec.containers[0].env[] | select(.name == "EXTRA") | .value' "1" "--set env.EXTRA=1 adds a variable"
kubeval on.yaml
