# construct3: select
#
# `select(cond)` passes its input through when cond is true and emits
# nothing otherwise. Combine conditions with `and`, `or`, `not`.
# Comparison is `==` / `!=`; a single `=` is *assignment* in jq.
#
# pods.json is `kubectl get pods -A -o json`. Print the names of the pods in
# namespace "prod" that are not Running: the ones to look at first.
#

.items[]
| select(.metadata.namespace == "prod")
| select(.status.phase = "Running")
| .metadata.name
