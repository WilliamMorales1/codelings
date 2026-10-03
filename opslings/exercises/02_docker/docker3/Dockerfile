# docker3 -- ARG versus ENV
#
# ARG is a build-time variable: `docker build --build-arg NAME=value`.
# ENV is baked into the image and visible to the running container.
# To ship a build argument to runtime you copy one into the other.
#
# One more rule: an ARG declared *before* FROM is only visible to the FROM
# line itself. Every stage has to declare the ARGs it uses.
#
# Task:
#   docker build -t opslings/docker3 --build-arg APP_VERSION=2.3.1 .
#   docker run --rm opslings/docker3        ->  version=2.3.1
# and without --build-arg the version must default to `dev`:
#   docker build -t opslings/docker3 . && docker run --rm opslings/docker3
#                                            ->  version=dev
#
# Right now it prints `version=` either way.
#

ARG APP_VERSION=dev

FROM alpine:3.20

ENV APP_VERSION=$APP_VERSION

CMD ["sh", "-c", "echo version=$APP_VERSION"]
