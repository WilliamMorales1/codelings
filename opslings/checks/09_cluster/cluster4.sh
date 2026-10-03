#!/usr/bin/env bash
# REQUIRES: docker kind kubectl yq
# HINT
# `kubectl get pods --show-labels` shows the Pods are labelled app=web, and
# nginx listens on 80 (the container port is named http):
#   selector:
#     app: web
#   ports:
#     - port: 80
#       targetPort: http
source "$OPSLINGS_ROOT/checks/lib.sh"

need_file service.yaml
expect_yq service.yaml '.spec.selector.app' "web" "selector in service.yaml"
tp=$(yq eval '.spec.ports[0].targetPort' service.yaml)
[[ "$tp" == 80 || "$tp" == http ]] || fail "targetPort '$tp' is not where nginx listens (80, named http)"
ok "targetPort points at nginx"
live_part
need_cluster
kc -n opslings get svc web >/dev/null 2>&1 || fail "no Service web in namespace opslings: kubectl --context kind-opslings apply -f service.yaml"
expect_eq "$(kc -n opslings get svc web -o jsonpath='{.spec.selector.app}')" "web" "selector in the cluster (did you apply?)"
ready() {
  kc -n opslings get endpointslices -l kubernetes.io/service-name=web \
    -o jsonpath='{range .items[*].endpoints[?(@.conditions.ready==true)]}{.addresses[0]}{"\n"}{end}' | grep -c .
}
n=0
for _ in $(seq 1 30); do
  n=$(ready)
  ((n >= 2)) && break
  sleep 1
done
((n >= 2)) || fail "Service web has $n ready endpoints, expected 2"
ok "2 ready endpoints"
expect_eq "$(kc -n opslings get endpointslices -l kubernetes.io/service-name=web -o jsonpath='{.items[0].ports[0].port}')" "80" "endpoint port"
