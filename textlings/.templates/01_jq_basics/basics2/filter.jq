# basics2: iterating with .[] and raw output with -r
#
# `.[]` emits every element of an array, one after the other, and
# `.items[]` is shorthand for `.items | .[]`. jq prints strings as JSON,
# with quotes; the -r (--raw-output) flag prints them bare, which is what
# you want when the next thing in the pipeline is `xargs` or `while read`.
#
# pods.json is `kubectl get pods -A -o json`: a List whose .items are Pods.
# Print every pod's name, one per line, without quotes.
#
# Flags go in the `flags` file next to this one; the check runs
#     jq $(cat flags) -f filter.jq pods.json
#

.items.metadata.name
