#!/usr/bin/env bash
# REQUIRES: kubeconform yq
# HINT
#   resources:
#     requests: { cpu: 100m, memory: 128Mi }
#     limits:   { memory: 256Mi }
# Probes should hit the port the app listens on -- 8080, or by name, `http`:
#   livenessProbe:
#     httpGet: { path: /healthz, port: http }
#     initialDelaySeconds: 5
source "$OPSLINGS_ROOT/checks/lib.sh"

need_file deployment.yaml
kubeval deployment.yaml
c='.spec.template.spec.containers[0]'
expect_yq deployment.yaml "$c.resources.requests.cpu" "100m" "cpu request"
expect_yq deployment.yaml "$c.resources.requests.memory" "128Mi" "memory request"
expect_yq deployment.yaml "$c.resources.limits.memory" "256Mi" "memory limit"
for probe in readinessProbe livenessProbe; do
  port=$(yq eval "$c.$probe.httpGet.port" deployment.yaml)
  [[ "$port" == 8080 || "$port" == http ]] || fail "$probe checks port '$port', but the app listens on 8080 (http)"
  ok "$probe uses the app's port"
done
expect_yq deployment.yaml "$c.readinessProbe.httpGet.path" "/ready" "readiness path"
expect_yq deployment.yaml "$c.livenessProbe.httpGet.path" "/healthz" "liveness path"
expect_yq deployment.yaml "($c.livenessProbe.initialDelaySeconds // 0) >= 5" "true" "liveness initialDelaySeconds >= 5"
