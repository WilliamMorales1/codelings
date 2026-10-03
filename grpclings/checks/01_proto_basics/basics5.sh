#!/usr/bin/env bash
# REQUIRES: protoc jq
# HINT
# Under `syntax`, add, in this order:
#   package shop.v1;
#   import "money.proto";
#   option go_package = "grpclings/exercises/01_proto_basics/basics5;basics5";
# and refer to the type by its full name: `common.v1.Money price = 3;`.
source "$GRPCLINGS_LIB"
go_check
