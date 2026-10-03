# basics4: compact output with -c
#
# By default jq pretty-prints. -c prints each result on a single line,
# which is what line-oriented tools (grep, wc -l, awk) expect.
#
# pod.json is one Pod. Print the resources block (limits and requests) of
# every container in the pod, one container per line.
#

.spec.containers[] | .resources
