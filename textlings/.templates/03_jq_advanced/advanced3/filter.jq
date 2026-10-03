# advanced3: reduce
#
# `reduce SOURCE as $x (INIT; UPDATE)` folds a stream into one value:
# start from INIT, and for each $x set . to UPDATE. `.[$k] += n` on an
# object creates the key if it is missing (null + n is n).
# (jq 1.8 also has add(f), e.g. add(.[].restartCount).)
#
# pods.json is `kubectl get pods -A -o json`. Build one object mapping each
# node to the total restart count of all containers of all pods on it:
#     {"node-b": 17, "node-a": 4, ...}
# Keys in order of first appearance.
#

reduce .items[] as $p (0; . + 1)   # TODO: this only counts pods
