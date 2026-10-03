#!/usr/bin/env bash
# REQUIRES: helm yq
# HINT
#   apiVersion: v2
#   name: hello
#   version: 0.1.0          (or "0.1.0")
#   appVersion: "1.10"      (the quotes matter)
#   type: application
source "$OPSLINGS_ROOT/checks/lib.sh"

need_file Chart.yaml values.yaml
helm_lint
expect_yq Chart.yaml '.apiVersion' "v2" "apiVersion"
expect_yq Chart.yaml '.name' "hello" "chart name"
expect_yq Chart.yaml '.version' "0.1.0" "chart version"
expect_yq Chart.yaml '.type' "application" "chart type"
scratch_copy
helm_render out.yaml
expect_yq out.yaml '.data.appVersion' "1.10" "rendered appVersion"
