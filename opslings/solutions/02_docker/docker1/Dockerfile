# docker1 -- FROM and CMD
#
# A Dockerfile starts FROM a base image and usually ends with CMD: the
# command a container runs when you do not pass one. CMD has two forms:
#
#   CMD ["executable", "arg1", "arg2"]    exec form: a JSON array, no shell
#   CMD executable arg1 arg2              shell form: run through /bin/sh -c
#
# Task: `docker run --rm opslings/docker1` must print exactly
#   hello from a container
#
# Try it yourself (from this directory):
#   docker build -t opslings/docker1 .
#   docker run --rm opslings/docker1
#
# The container dies with "executable file not found". Read the exec form
# above again: what is the executable here?
#

FROM alpine:3.20

CMD ["echo", "hello from a container"]
