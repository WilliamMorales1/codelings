# basics1: field access
#
# `.foo` reads key "foo" of an object; `.foo.bar` walks into nested ones.
# A comma runs two filters on the same input and emits both results.
#
# pod.json is one Pod, as printed by `kubectl get pod NAME -o json`.
# Print the pod's name (metadata.name), then the node it is scheduled on
# (spec.nodeName).
#
# Run: jq -f filter.jq pod.json

.metadata.name, .spec.nodeName
