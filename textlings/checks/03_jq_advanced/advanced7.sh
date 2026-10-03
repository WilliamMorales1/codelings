#!/usr/bin/env bash
# REQUIRES: jq
# HINT
# .metadata.annotations.kubectl.kubernetes.io/last-applied-configuration
# is parsed as the path .kubectl.kubernetes.io divided by something
# else. Quote the key:
# .metadata.annotations["kubectl.kubernetes.io/last-applied-configuration"]
source "$TEXTLINGS_ROOT/checks/lib.sh"

expect_out jq expected.txt -- deployment.json
expect_out --label "same program on a second, hidden input" jq "$FIX/expected.txt" -- "$FIX/deployment.json"
