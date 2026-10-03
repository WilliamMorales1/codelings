# docker5 -- multi-stage builds
#
# This image works, but it ships the entire Go toolchain just to run one
# small static binary: several hundred MB to pull on every deploy, and a
# compiler handed to anyone who gets a shell in your container.
#
# A multi-stage build compiles in one stage and copies only the result into
# a tiny final stage:
#
#   FROM golang:alpine AS build
#   ...
#   FROM scratch                       # literally empty
#   COPY --from=build /out/hello /hello
#
# `scratch` has no libc, so the binary must be static: build with
# CGO_ENABLED=0.
#
# Task: the final image must be under 20 MB and still print
#   hello from linux/amd64, no OS required      (or your arch)
#
#   docker build -t opslings/docker5 .
#   docker image ls opslings/docker5
#   docker run --rm opslings/docker5
#

FROM golang:alpine AS build
WORKDIR /src
COPY go.mod main.go ./
RUN CGO_ENABLED=0 go build -ldflags="-s -w" -o /out/hello .

FROM scratch
COPY --from=build /out/hello /hello
ENTRYPOINT ["/hello"]
