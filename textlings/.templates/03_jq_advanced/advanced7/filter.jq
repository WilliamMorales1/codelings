# advanced7: del
#
# `del(path, path, ...)` removes paths. A key that is not a plain
# identifier (dots, slashes, dashes) needs quoting: .metadata.annotations["a.b/c"]
# or ."a.b/c". The opposite, keeping only some paths, is pick (jq 1.7+).
#
# deployment.json came from `kubectl get deploy NAME -o json`. Before
# committing it to git, strip what the server manages: .status,
# metadata.uid, metadata.resourceVersion, metadata.creationTimestamp,
# metadata.generation, metadata.managedFields, and the two annotations
# kubectl.kubernetes.io/last-applied-configuration and
# deployment.kubernetes.io/revision.
#

del(.status, .metadata.uid, .metadata.resourceVersion)
| del(.metadata.annotations.kubectl.kubernetes.io/last-applied-configuration)
# TODO: the rest of the list
