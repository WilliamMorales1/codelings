#!/usr/bin/env bash
# REQUIRES: protoc jq
# HINT
# Save: b, err := proto.Marshal(list), then os.WriteFile.
# Load: list := &TodoList{}; proto.Unmarshal(b, list). Import
# "google.golang.org/protobuf/proto" and drop encoding/json.
source "$GRPCLINGS_LIB"
go_check
