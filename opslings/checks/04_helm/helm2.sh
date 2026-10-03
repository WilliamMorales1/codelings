#!/usr/bin/env bash
# REQUIRES: helm yq kubeconform
# HINT
# Compare every .Values path with values.yaml, key by key:
#   .Values.replicas            -> .Values.replicaCount
#   .Values.image.repo          -> .Values.image.repository
#   .Values.service.target_port -> .Values.service.targetPort
source "$OPSLINGS_ROOT/checks/lib.sh"

need_file Chart.yaml values.yaml templates/deployment.yaml
scratch_copy
helm_lint
helm_render out.yaml
d='select(.kind == "Deployment")'
expect_yq out.yaml "$d | .spec.replicas" "2" "replicas"
expect_yq out.yaml "$d | .spec.template.spec.containers[0].image" "ghcr.io/acme/api:1.4.2" "image"
expect_yq out.yaml "$d | .spec.template.spec.containers[0].ports[0].containerPort" "8080" "containerPort"
helm_render out2.yaml --set replicaCount=5 --set image.tag=2.0.0 --set service.targetPort=9090
expect_yq out2.yaml "$d | .spec.replicas" "5" "replicas with --set replicaCount=5"
expect_yq out2.yaml "$d | .spec.template.spec.containers[0].image" "ghcr.io/acme/api:2.0.0" "image with --set image.tag=2.0.0"
expect_yq out2.yaml "$d | .spec.template.spec.containers[0].ports[0].containerPort" "9090" "containerPort with --set service.targetPort=9090"
kubeval out.yaml
