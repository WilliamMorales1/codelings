#!/usr/bin/env bash
# REQUIRES: docker
# HINT
# Add `USER web` (or `USER 10001`) before CMD; everything after it, including
# the running container, uses that user.
# The health check asks port 80, but httpd listens on 8080:
#   CMD wget -q -O /dev/null http://127.0.0.1:8080/ || exit 1
source "$OPSLINGS_ROOT/checks/lib.sh"

need_file Dockerfile site/index.html
need_docker
docker_build opslings/docker6
user=$(docker image inspect -f '{{.Config.User}}' opslings/docker6)
[[ -n "$user" && "$user" != root && "$user" != 0 ]] || fail "image runs as root (Config.User is '${user}')"
ok "image user is $user"
[[ -n "$(docker image inspect -f '{{.Config.Healthcheck}}' opslings/docker6 | grep -v '<nil>')" ]] || fail "image has no HEALTHCHECK"
name=opslings-docker6-$$
docker_detached "$name" opslings/docker6
expect_eq "$(docker exec "$name" id -u 2>&1)" "10001" "uid inside the container"
status=""
for _ in $(seq 1 30); do
  status=$(docker inspect -f '{{.State.Health.Status}}' "$name" 2>/dev/null)
  [[ "$status" == healthy || "$status" == unhealthy ]] && break
  sleep 1
done
if [[ "$status" != healthy ]]; then
  docker inspect -f '{{range .State.Health.Log}}{{.Output}}{{end}}' "$name" | tail -5
  fail "container health is '$status', expected healthy"
fi
ok "container is healthy"
