#!/usr/bin/env bash
# REQUIRES: jq diff sort sed
# HINT
# Write a small shell function that prints the sorted lines for one file:
# jq -r '.items[] | "\(.metadata.namespace)/\(.metadata.name)" as $d
#        | .spec.template.spec.containers[] | "\($d)/\(.name)=\(.image)"' "$1" | sort
# Then diff <(images "$1") <(images "$2") and keep only the < and > lines,
# rewritten to - and +: sed -n 's/^< /- /p; s/^> /+ /p'
source "$TEXTLINGS_ROOT/checks/lib.sh"

expect_out sh expected.txt -- before.json after.json
expect_out --label "same program on a second, hidden input" sh "$FIX/expected.txt" -- "$FIX/before.json" "$FIX/after.json"
