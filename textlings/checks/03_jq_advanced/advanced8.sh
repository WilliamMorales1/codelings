#!/usr/bin/env bash
# REQUIRES: jq
# HINT
# The hidden input is a CronJob, where containers sit under
# .spec.jobTemplate.spec.template.spec. Do not hard-code the path:
# paths as $p | select($p[-1] == "image") | "\($p | map(tostring) | join(".")): \(getpath($p))"
source "$TEXTLINGS_ROOT/checks/lib.sh"

expect_out jq expected.txt -- deployment.json
expect_out --label "same program on a second, hidden input" jq "$FIX/expected.txt" -- "$FIX/cronjob.json"
