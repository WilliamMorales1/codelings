#!/usr/bin/env bash
# REQUIRES: docker
# HINT
# Make `greet` the ENTRYPOINT and leave only the default argument in CMD:
#   ENTRYPOINT ["greet"]
#   CMD ["world"]
# Use the exec (JSON) form: a shell-form ENTRYPOINT ignores CMD and the
# arguments from `docker run` entirely.
source "$OPSLINGS_ROOT/checks/lib.sh"

need_file Dockerfile greet.sh
need_docker
docker_build opslings/docker7
expect_eq "$(docker run --rm opslings/docker7 2>&1)" "Hello, world!" "docker run opslings/docker7"
expect_eq "$(docker run --rm opslings/docker7 Alice 2>&1)" "Hello, Alice!" "docker run opslings/docker7 Alice"
expect_match "$(docker image inspect -f '{{json .Config.Entrypoint}}' opslings/docker7)" 'greet' "ENTRYPOINT runs greet"
