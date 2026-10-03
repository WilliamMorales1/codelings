# docker2 -- COPY and WORKDIR
#
# WORKDIR sets the current directory for every instruction after it (and for
# the running container). A relative COPY destination such as `.` means "the
# current WORKDIR", which is `/` until you set one.
#
# Task: put greet.sh and motd.txt in /srv, and make the container start in
# /srv so that `docker run --rm opslings/docker2` prints
#   Welcome aboard, operator.
#
#   docker build -t opslings/docker2 .
#   docker run --rm opslings/docker2
#   docker run --rm opslings/docker2 ls -la      # where did the files go?
#

FROM alpine:3.20

WORKDIR /srv
COPY greet.sh .
COPY motd.txt .

CMD ["sh", "greet.sh"]
