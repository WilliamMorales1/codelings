#!/usr/bin/env bash
#       pipelines3: diff two API responses
#
#       Raw JSON from two API calls differs everywhere (uids, timestamps,
#       resourceVersions). Reduce each side to the lines you care about, sort
#       them, then compare. `diff <(cmd1) <(cmd2)` compares the output of two
#       commands through bash process substitution.
#
#       before.json and after.json are `kubectl get deploy -o json` from before
#       and after a release. List the container images that changed, one line
#       per deployment/container=image, "-" for lines only in before, "+" for
#       lines only in after, in the order diff prints them (inputs sorted):
#           - prod/payments/payments=registry.acme.io/payments:5.0.1
#           + prod/payments/payments=registry.acme.io/payments:5.0.2
#       (a line is  namespace/deployment/container=image).
#
# The check runs  bash pipeline.sh before.json after.json  and compares stdout with
# expected.txt. Use the arguments ("$1"...), never the file names.
# The check sets LC_ALL=C, so sort compares bytes; do the same when you
# try it by hand:  LC_ALL=C bash pipeline.sh before.json after.json

images() {
  jq -r '.items[]
    | "\(.metadata.namespace)/\(.metadata.name)" as $d
    | .spec.template.spec.containers[]
    | "\($d)/\(.name)=\(.image)"' "$1" | sort
}

diff <(images "$1") <(images "$2") | sed -n 's/^< /- /p; s/^> /+ /p'
