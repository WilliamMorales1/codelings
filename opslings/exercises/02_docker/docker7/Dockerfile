# docker7 -- ENTRYPOINT versus CMD
#
# When both are set, the container runs  ENTRYPOINT + CMD, and anything you
# type after the image name in `docker run IMAGE ...` *replaces CMD*:
#
#   ENTRYPOINT  the program; always runs
#   CMD         its default arguments; easy to override
#
# That split is how images like `alpine/git` behave like a command-line tool.
#
# Task: make the image behave like this:
#   docker run --rm opslings/docker7            ->  Hello, world!
#   docker run --rm opslings/docker7 Alice      ->  Hello, Alice!
#
# Right now the second one fails: Docker tries to execute a program called
# "Alice".
#

FROM alpine:3.20
COPY --chmod=755 greet.sh /usr/local/bin/greet
CMD ["greet", "world"]
