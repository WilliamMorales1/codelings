#!/usr/bin/env bash
# REQUIRES: docker
# HINT
# Order matters: the two COPY lines run while the working directory is still
# `/`. Move `WORKDIR /srv` above them (or COPY to /srv/ explicitly).
source "$OPSLINGS_ROOT/checks/lib.sh"

need_file Dockerfile greet.sh motd.txt
need_docker
docker_build opslings/docker2
expect_eq "$(docker run --rm opslings/docker2 pwd 2>&1)" "/srv" "container starts in /srv"
files=$(docker run --rm opslings/docker2 ls /srv 2>&1 | tr '\n' ' ')
expect_eq "$files" "greet.sh motd.txt " "files in /srv"
out=$(docker run --rm opslings/docker2 2>&1) || fail "container exited non-zero: $out"
expect_eq "$out" "Welcome aboard, operator." "container output"
