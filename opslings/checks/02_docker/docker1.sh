#!/usr/bin/env bash
# REQUIRES: docker
# HINT
# In exec form every JSON string is one argv entry, so Docker looks for a
# program literally named "echo hello from a container". Split it:
#   CMD ["echo", "hello from a container"]
source "$OPSLINGS_ROOT/checks/lib.sh"

need_file Dockerfile
need_docker
docker_build opslings/docker1
out=$(docker run --rm opslings/docker1 2>&1) || fail "container exited non-zero: $out"
expect_eq "$out" "hello from a container" "container output"
