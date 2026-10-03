#!/usr/bin/env bash
# Maintainer tool: regenerate the *.pb.go files shipped next to exercises and
# solutions (they exist only so editors can resolve the generated types; checks
# always regenerate). Skips dirs where generating is the exercise, and dirs
# whose .proto is deliberately broken.
set -uo pipefail
cd "$(dirname "$0")/.."
root=$PWD
pgg=$(go tool -n protoc-gen-go) || exit 1
pggg=$(go tool -n protoc-gen-go-grpc) || exit 1
for tree in solutions exercises; do
  for dir in "$tree"/*/*/; do
    dir=${dir%/}
    compgen -G "$dir/*.proto" >/dev/null || continue
    [[ -e "$dir/buf.gen.yaml" || -e "$dir/gen.sh" ]] && continue
    # Only dirs with hand-written Go code need generated code on disk.
    ls "$dir"/*.go 2>/dev/null | grep -vq '\.pb\.go$' || continue
    rm -f "$dir"/*.pb.go
    (cd "$dir" && protoc -I . --plugin=protoc-gen-go="$pgg" --plugin=protoc-gen-go-grpc="$pggg" \
      --go_out=. --go_opt=paths=source_relative \
      --go-grpc_out=. --go-grpc_opt=paths=source_relative ./*.proto 2>/dev/null) ||
      echo "not generated (proto does not compile): $dir"
  done
done
# .templates mirrors exercises exactly.
rm -rf .templates && cp -a exercises .templates
