#!/usr/bin/env bash
# REQUIRES: docker
# HINT
# The ARG above FROM is out of scope inside the stage, so $APP_VERSION expands
# to nothing. Declare it after FROM (you can keep or drop the one above):
#   FROM alpine:3.20
#   ARG APP_VERSION=dev
#   ENV APP_VERSION=$APP_VERSION
source "$OPSLINGS_ROOT/checks/lib.sh"

need_file Dockerfile
need_docker
docker_build opslings/docker3 --build-arg APP_VERSION=2.3.1
expect_eq "$(docker run --rm opslings/docker3 2>&1)" "version=2.3.1" "with --build-arg APP_VERSION=2.3.1"
env=$(docker image inspect -f '{{range .Config.Env}}{{println .}}{{end}}' opslings/docker3)
grep -qx 'APP_VERSION=2.3.1' <<<"$env" || fail "APP_VERSION=2.3.1 is not in the image's ENV (docker image inspect opslings/docker3)"
ok "APP_VERSION is part of the image config"
docker_build opslings/docker3
expect_eq "$(docker run --rm opslings/docker3 2>&1)" "version=dev" "without --build-arg"
