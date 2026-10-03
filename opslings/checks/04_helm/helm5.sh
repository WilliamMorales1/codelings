#!/usr/bin/env bash
# REQUIRES: helm yq kubeconform
# HINT
#   replicas: {{ .Values.replicaCount | default 1 }}
#   image: "{{ .Values.image.repository }}:{{ .Values.image.tag | default .Chart.AppVersion }}"
#   value: {{ required "database.host is required" .Values.database.host | quote }}
source "$OPSLINGS_ROOT/checks/lib.sh"

need_file Chart.yaml values.yaml templates/deployment.yaml
scratch_copy
if err=$(helm template demo . 2>&1); then
  fail "helm template without database.host should fail, but it rendered"
fi
grep -q 'database.host' <<<"$err" || fail "the error should mention database.host; got: $err"
ok "rendering without database.host fails: $(grep -o 'database.host[^"]*' <<<"$err" | head -1)"
d='select(.kind == "Deployment")'
helm_render out.yaml --set database.host=db.internal
expect_yq out.yaml "$d | .spec.replicas" "1" "replicas default to 1"
expect_yq out.yaml "$d | .spec.template.spec.containers[0].image" "ghcr.io/acme/worker:5.4.0" "image tag defaults to appVersion"
expect_yq out.yaml "$d | .spec.template.spec.containers[0].env[0].value" "db.internal" "DB_HOST"
kubeval out.yaml
helm_render out2.yaml --set database.host=db.internal --set image.tag=5.5.0-rc1 --set replicaCount=3
expect_yq out2.yaml "$d | .spec.replicas" "3" "--set replicaCount=3"
expect_yq out2.yaml "$d | .spec.template.spec.containers[0].image" "ghcr.io/acme/worker:5.5.0-rc1" "--set image.tag wins over appVersion"
