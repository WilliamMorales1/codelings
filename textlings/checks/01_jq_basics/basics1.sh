#!/usr/bin/env bash
# REQUIRES: jq
# HINT
# A missing key is not an error in jq, it is just null, which is why the
# broken version prints null twice. Look at pod.json: name lives under
# "metadata", nodeName under "spec". So: .metadata.name, .spec.nodeName
source "$TEXTLINGS_ROOT/checks/lib.sh"

expect_out jq expected.txt -- pod.json
expect_out --label "same program on a second, hidden input" jq "$FIX/expected.txt" -- "$FIX/pod.json"
