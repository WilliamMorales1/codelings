#!/usr/bin/env bash
# REQUIRES: yq
# HINT
# Quote strings, leave numbers bare:  .image.tag = "1.5.0" | .replicaCount = 3
# Assigning to a key that does not exist creates it:  .podLabels.team = "platform"
# And  del(.debug)  removes a key with everything under it.
source "$OPSLINGS_ROOT/checks/lib.sh"

need_file update.yq values.yaml
scratch_copy
out=$(yq -i --from-file update.yq values.yaml 2>&1) || fail "yq error: $out"
expect_yq values.yaml '.image.tag' "1.5.0" "image.tag"
expect_yq values.yaml '.image.tag | tag' '!!str' "image.tag is a string"
expect_yq values.yaml '.replicaCount' "3" "replicaCount"
expect_yq values.yaml '.replicaCount | tag' '!!int' "replicaCount is a number"
expect_yq values.yaml '.podLabels.team' "platform" "podLabels.team"
expect_yq values.yaml 'has("debug")' "false" "debug block removed"
diff -u "$OPSLINGS_ROOT/checks/01_yq/fixtures/yq3-expected.yaml" values.yaml || fail "values.yaml differs from the expected result (diff above)"
ok "values.yaml matches the expected release values"
