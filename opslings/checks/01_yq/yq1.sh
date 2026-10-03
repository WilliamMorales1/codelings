#!/usr/bin/env bash
# REQUIRES: yq
# HINT
# The Pod spec of a Deployment lives under .spec.template.spec, so the first
# container is .spec.template.spec.containers[0]. Arrays index from 0.
source "$OPSLINGS_ROOT/checks/lib.sh"

need_file query.yq deployment.yaml
got=$(yq --from-file query.yq deployment.yaml 2>&1) || fail "yq error: $got"
expect_eq "$got" "ghcr.io/acme/api:1.4.2" "image of the first container"
got=$(yq --from-file query.yq "$OPSLINGS_ROOT/checks/01_yq/fixtures/yq1-other.yaml" 2>&1)
expect_eq "$got" "registry.example.com/billing:2.0.0" "same query on a different Deployment (no hard-coding)"
