# basics6: defaults with //
#
# `a // b` gives the outputs of a, unless a produces nothing but null or
# false, in which case it gives b. It is jq's "value or default".
# (Careful: a real `false` also falls through to the default.)
#
# pods.json is `kubectl get pods -A -o json`. Print each pod's `app` label
# (metadata.labels.app), one per line. Some pods have no app label: print
# `(none)` for those instead of `null`.

.items[] | .metadata.labels.app // "(none)"
