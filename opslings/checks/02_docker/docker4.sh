#!/usr/bin/env bash
# REQUIRES: docker
# HINT
# The patterns in .dockerignore do not match the real names: the file is
# `.env` and the directory is `secrets/`. Add NOTES.md too. Patterns are
# relative to the context root, e.g.
#   .env
#   secrets/
#   NOTES.md
source "$OPSLINGS_ROOT/checks/lib.sh"

need_file Dockerfile .dockerignore public/index.html
need_docker
grep -q '^COPY \. \.' Dockerfile || fail "keep 'COPY . .' in the Dockerfile; fix .dockerignore instead"
docker_build opslings/docker4
tree=$(docker run --rm opslings/docker4 find /app 2>&1)
grep -qx '/app/public/index.html' <<<"$tree" || fail "/app/public/index.html is missing from the image:"$'\n'"$tree"
ok "public/index.html is in the image"
for leak in /app/.env /app/secrets /app/NOTES.md; do
  if grep -q "^$leak" <<<"$tree"; then
    fail "$leak made it into the image"
  fi
done
ok "no .env, secrets/ or NOTES.md in the image"
