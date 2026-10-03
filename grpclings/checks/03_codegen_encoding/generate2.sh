#!/usr/bin/env bash
# REQUIRES: jq
# HINT
# Each plugin entry takes `opt: paths=source_relative` (or a list of options).
# Add a second entry whose local command is ["go", "tool", "protoc-gen-go-grpc"],
# with the same out and opt.
source "$GRPCLINGS_LIB"
need_file buf.gen.yaml
module_scratch
rm -rf ./*.pb.go grpclings
out=$(run_buf generate 2>&1) || { echo "$out"; fail "buf generate failed"; }
ok "buf generate ran"
[[ -f notes.pb.go ]] || fail "buf generate did not write notes.pb.go next to notes.proto (found: $(find . -name '*.pb.go' | tr '\n' ' '))"
ok "notes.pb.go is next to notes.proto"
[[ -f notes_grpc.pb.go ]] || fail "buf generate did not write notes_grpc.pb.go: add the protoc-gen-go-grpc plugin"
ok "notes_grpc.pb.go is next to notes.proto"
go_check --no-regen
