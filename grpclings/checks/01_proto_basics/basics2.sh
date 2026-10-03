#!/usr/bin/env bash
# REQUIRES: protoc jq
# HINT
# Match comment to type: "only goes up, 64 bits" is uint64; "float64" is double;
# "small and often negative" is sint64 (zigzag); "uniformly random 32-bit" is
# fixed32 (a varint would need 5 bytes for most values); "not text" is bytes.
source "$GRPCLINGS_LIB"
go_check
