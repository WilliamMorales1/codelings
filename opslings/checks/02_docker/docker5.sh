#!/usr/bin/env bash
# REQUIRES: docker
# HINT
#   FROM golang:alpine AS build
#   WORKDIR /src
#   COPY go.mod main.go ./
#   RUN CGO_ENABLED=0 go build -ldflags="-s -w" -o /out/hello .
#
#   FROM scratch
#   COPY --from=build /out/hello /hello
#   ENTRYPOINT ["/hello"]
# (gcr.io/distroless/static is a fine alternative to scratch.)
source "$OPSLINGS_ROOT/checks/lib.sh"

need_file Dockerfile main.go go.mod
need_docker
docker_build opslings/docker5
out=$(docker run --rm opslings/docker5 2>&1) || fail "container exited non-zero: $out"
expect_match "$out" '^hello from linux/[a-z0-9]+, no OS required$' "container output"
size=$(docker image inspect -f '{{.Size}}' opslings/docker5)
(( size < 20 * 1024 * 1024 )) || fail "image is $((size / 1024 / 1024)) MB; it must be under 20 MB"
ok "image is $((size / 1024)) KB"
if docker run --rm --entrypoint go opslings/docker5 version >/dev/null 2>&1; then
  fail "the Go toolchain is still in the final image"
fi
ok "no Go toolchain in the final image"
