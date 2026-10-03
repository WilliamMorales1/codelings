#!/usr/bin/env bash
# REQUIRES: protoc jq
# HINT
# Add `--go_opt=paths=source_relative` so notes.pb.go lands next to the proto.
# For the service you need the second plugin: another --plugin line for
# protoc-gen-go-grpc, plus `--go-grpc_out=. --go-grpc_opt=paths=source_relative`.
source "$GRPCLINGS_LIB"
need_file gen.sh
module_scratch
rm -rf ./*.pb.go grpclings
out=$(bash gen.sh 2>&1) || { echo "$out"; fail "gen.sh failed"; }
ok "gen.sh ran"
[[ -f notes.pb.go ]] || fail "gen.sh did not write notes.pb.go next to notes.proto (found: $(find . -name '*.pb.go' | tr '\n' ' '))"
ok "notes.pb.go is next to notes.proto"
[[ -f notes_grpc.pb.go ]] || fail "gen.sh did not write notes_grpc.pb.go: the service needs protoc-gen-go-grpc"
ok "notes_grpc.pb.go is next to notes.proto"
go_check --no-regen
