#!/usr/bin/env bash
# REQUIRES: docker yq jq
# HINT
# The dependency is called `database` but the service is `db`, and a named
# volume must also be declared in a top-level `volumes:` map:
#   volumes:
#     pgdata: {}
# Then, on api:
#     ports: ["8080:8080"]
#     depends_on:
#       db:
#         condition: service_healthy
# and on db:
#     healthcheck:
#       test: ["CMD-SHELL", "pg_isready -U app"]
#       interval: 5s
source "$OPSLINGS_ROOT/checks/lib.sh"

need_file compose.yaml
docker compose version >/dev/null 2>&1 || fail "the compose plugin is missing: install docker-compose (or Docker's docker-compose-plugin)"
yq eval '.' compose.yaml >/dev/null 2>&1 || fail "compose.yaml is not valid YAML: $(yq eval . compose.yaml 2>&1)"
cfg=$(docker compose -p opslings-docker8 -f compose.yaml config --format json 2>&1) || { echo "$cfg"; fail "docker compose config rejected compose.yaml"; }
ok "docker compose config accepts compose.yaml"
q() { jq -r "$1" <<<"$cfg"; }
expect_eq "$(q '.services.api.depends_on.db.condition')" "service_healthy" "api waits for a healthy db"
expect_match "$(q '.services.db.healthcheck.test | join(" ")')" 'pg_isready' "db healthcheck uses pg_isready"
expect_eq "$(q '.services.api.ports[0] | "\(.published):\(.target)"')" "8080:8080" "api port mapping"
expect_eq "$(q '.services.db.volumes[0] | "\(.type) \(.source) \(.target)"')" "volume pgdata /var/lib/postgresql/data" "db data volume"
expect_eq "$(q '.volumes | has("pgdata")')" "true" "pgdata declared as a named volume"
