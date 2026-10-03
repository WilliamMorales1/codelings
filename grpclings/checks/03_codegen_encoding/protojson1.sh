#!/usr/bin/env bash
# REQUIRES: protoc jq
# HINT
# protojson.MarshalOptions{UseProtoNames: true, EmitUnpopulated: true}.Marshal(ev)
# and protojson.UnmarshalOptions{DiscardUnknown: true}.Unmarshal(b, ev).
source "$GRPCLINGS_LIB"
go_check
