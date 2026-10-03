#!/usr/bin/env bash
# REQUIRES: protoc jq
# HINT
# Check mask.IsValid(dst) first. Then loop over mask.GetPaths() with a switch:
# "name" -> dst.Name = src.GetName(), "email" likewise, "address" ->
# dst.Address = proto.CloneOf(src.GetAddress()), anything else -> error.
# proto.Merge is wrong twice over: it copies every set field, and it never
# clears a field that src left empty.
source "$GRPCLINGS_LIB"
go_check
