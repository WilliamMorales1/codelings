#!/usr/bin/env bash
# generate1: running protoc yourself
#
# protoc parses .proto files; PLUGINS write the code. For Go you need two:
#   protoc-gen-go       messages   -> notes.pb.go       (--go_out)
#   protoc-gen-go-grpc  services   -> notes_grpc.pb.go  (--go-grpc_out)
# protoc looks for a binary named protoc-gen-NAME for every --NAME_out flag.
# This course pins both in go.mod (`tool` directives), and `go tool -n NAME`
# prints the path of the cached, built binary, which --plugin accepts.
#
# By default protoc-gen-go writes to a path built from the go_package import
# path (./grpclings/exercises/...). paths=source_relative puts the output next
# to the .proto instead.
#
# Task: fix this script so that `bash gen.sh`, run in this directory, writes
# notes.pb.go AND notes_grpc.pb.go right here. Try it, then `ls`.
set -euo pipefail
cd "$(dirname "$0")"

protoc -I . \
  --plugin=protoc-gen-go="$(go tool -n protoc-gen-go)" \
  --plugin=protoc-gen-go-grpc="$(go tool -n protoc-gen-go-grpc)" \
  --go_out=. --go_opt=paths=source_relative \
  --go-grpc_out=. --go-grpc_opt=paths=source_relative \
  notes.proto
