# advanced10: update-assignment |=, +=, *=
#
# `.a = v` sets a path; `.a |= f` runs f on the old value; `.a += v`,
# `.a *= v` are shorthands. The left side may be any path expression,
# including iterations like `.containers[].x`, which updates every match.
# The result is the whole document, modified.
#
# deployment.json is a Deployment. For a staging copy: double
# spec.replicas, add the label env=staging to metadata.labels, and set
# imagePullPolicy to "Always" on every container.

.spec.replicas *= 2
| .metadata.labels += {env: "staging"}
| .spec.template.spec.containers[].imagePullPolicy = "Always"
