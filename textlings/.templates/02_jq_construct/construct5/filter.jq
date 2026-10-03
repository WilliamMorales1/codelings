# construct5: from_entries
#
# `from_entries` is the inverse of to_entries: an array of
# {key, value} objects becomes one object. It also accepts "name" instead
# of "key", which is exactly the shape of a Kubernetes env list.
#
# deployment.json is `kubectl get deploy NAME -o json`. Turn the env list
# of the first container into one object, e.g.
#     {"LOG_LEVEL": "info", "PORT": "8080"}
#

.spec.template.spec.containers[0].env | map({(.name): .value})
