#!/usr/bin/env bash
# REQUIRES: protoc jq
# HINT
# `optional int32 volume = 2;` makes the Go field `Volume *int32`.
# GetVolume() still returns 0 for nil, so it cannot tell the cases apart:
# test `s.Volume == nil` instead (or `s.ProtoReflect().Has(...)`).
source "$GRPCLINGS_LIB"
go_check
