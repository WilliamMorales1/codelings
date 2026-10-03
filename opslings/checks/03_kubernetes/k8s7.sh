#!/usr/bin/env bash
# REQUIRES: kubeconform yq
# HINT
# apiVersion: networking.k8s.io/v1, and drop the annotation for
#   spec:
#     ingressClassName: nginx
# Each path then looks like:
#   - path: /api
#     pathType: Prefix
#     backend:
#       service:
#         name: api
#         port:
#           number: 8080
source "$OPSLINGS_ROOT/checks/lib.sh"

need_file ingress.yaml
kubeval ingress.yaml
expect_yq ingress.yaml '.apiVersion' "networking.k8s.io/v1" "apiVersion"
expect_yq ingress.yaml '.spec.ingressClassName' "nginx" "ingressClassName"
expect_yq ingress.yaml '.metadata.annotations["kubernetes.io/ingress.class"] // "gone"' "gone" "deprecated class annotation removed"
expect_yq ingress.yaml '.spec.rules[0].host' "shop.example.com" "host"
route() {
  yq eval ".spec.rules[0].http.paths[] | select(.path == \"$1\") | .pathType + \" \" + .backend.service.name + \":\" + (.backend.service.port.number | tostring)" ingress.yaml
}
expect_eq "$(route /)" "Prefix web:80" "route /"
expect_eq "$(route /api)" "Prefix api:8080" "route /api"
