# advanced11: --arg, --argjson and $ENV
#
# `--arg name v` binds $name to the *string* v; `--argjson name v` parses
# v as JSON, so numbers stay numbers. `$ENV.VAR` (or env.VAR) reads an
# environment variable. Never paste shell variables into the filter text.
#
# The check runs this filter as
#     CLUSTER=prod-eu jq -r --arg ns shop --argjson min 3 -f filter.jq pods.json
# (and again with other values). Print the pods in namespace $ns whose
# containers restarted at least $min times in total, as
#     prod-eu/shop/api-1a2b3c: 5 restarts

.items[]
| select(.metadata.namespace == $ns)
| (.status.containerStatuses | map(.restartCount) | add) as $r
| select($r >= $min)
| "\($ENV.CLUSTER)/\($ns)/\(.metadata.name): \($r) restarts"
