# advanced8: paths and getpath
#
# `paths` emits the path (an array like ["spec","containers",0,"image"])
# of every value in the document; `paths(f)` only those whose value
# matches f. `getpath(p)` reads the value at p, `setpath(p; v)` writes it.
# Handy when the same field sits at different depths in different kinds.
#
# deployment.json is a Deployment. Print every container image in the
# document, whatever the kind (Deployment, CronJob with initContainers,
# ...), as  dotted.path: image  in document order:
#     spec.template.spec.containers.0.image: docker.io/library/nginx:1.29.1
#

.spec.template.spec.containers | to_entries[] | "spec.template.spec.containers.\(.key).image: \(.value.image)"
