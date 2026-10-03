# construct1: building objects
#
# `{name: .metadata.name}` builds a new object. `{namespace}` is short for
# `{namespace: .namespace}`. If a value expression has several outputs,
# you get one object per combination, so build the object *inside* the
# iteration, not around it.
#
# pods.json is `kubectl get pods -A -o json`. For every pod print one
# compact line: {"name":..,"namespace":..,"node":..,"phase":..}
# (node is spec.nodeName, phase is status.phase).
#

{
  name: .items[].metadata.name,
  namespace: .items[].metadata.namespace,
  node: .items[].spec.nodeName,
  phase: .items[].status.phase
}
