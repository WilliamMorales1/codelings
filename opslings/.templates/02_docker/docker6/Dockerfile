# docker6 -- USER and HEALTHCHECK
#
# Containers run as root unless you say otherwise, and a process escaping a
# root container is a much worse day than one escaping as uid 10001. Most
# clusters (Pod Security "restricted") refuse root containers outright.
#
# HEALTHCHECK tells Docker how to ask the app whether it is actually working;
# `docker ps` then shows (healthy) / (unhealthy), and orchestrators act on it.
#
# Task:
#   - the container must run as the `web` user (uid 10001) created below
#   - the HEALTHCHECK must succeed, so the container turns (healthy)
#
#   docker build -t opslings/docker6 .
#   docker run -d --name d6 opslings/docker6
#   docker ps                                          # watch the STATUS column
#   docker inspect -f '{{json .State.Health}}' d6      # health check log
#   docker exec d6 id
#   docker rm -f d6
#

FROM busybox:1.36
RUN adduser -D -H -u 10001 web
COPY site/ /www/
EXPOSE 8080

# TODO: stop running as root

HEALTHCHECK --interval=2s --timeout=2s --retries=3 \
  CMD wget -q -O /dev/null http://127.0.0.1/ || exit 1

CMD ["httpd", "-f", "-p", "8080", "-h", "/www"]
