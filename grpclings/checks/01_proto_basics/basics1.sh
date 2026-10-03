#!/usr/bin/env bash
# REQUIRES: protoc jq
# HINT
# Three separate problems, and protoc reports them one by one:
# - `int` is not a protobuf type; the 32-bit signed integer is `int32`.
# - every field needs `= N;`, and N must be unique inside the message.
# - 19000-19999 is reserved for the protobuf implementation.
# Follow the numbers in the spec at the top of the file.
source "$GRPCLINGS_LIB"
go_check
