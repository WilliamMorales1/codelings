#!/usr/bin/env bash
# REQUIRES: protoc jq
# HINT
# Inside the message:
#   reserved 3;
#   reserved "email";
# and `string nickname = 5;`. protoc then refuses any field numbered 3 or
# named email, which is the point.
source "$GRPCLINGS_LIB"
go_check
